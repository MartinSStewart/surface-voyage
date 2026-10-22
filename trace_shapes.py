"""Trace the shapes drawn on the minimap (src/WorldShapes.elm) from the world's texture.

Run from anywhere: python3 trace_shapes.py, then elm-format src/WorldShapes.elm
Needs numpy, scipy, pillow, opencv-python, scikit-image and shapely.

The surface is unfolded flat in two charts: the slab (x, and the distance round the slab's cross
section), which unrolls the top, bottom, rounded edges and long sides without stretching, and the
hole (angle round it, and a conformal coordinate down it). The world model's triangles are drawn into
each chart with their texture, black is traced into wall lines and the sandy colour into filled
areas, and the results are clipped to each chart's own part of the surface and taken back to 3D.
The ends of the slab (the x faces) aren't traced.
"""
import os
import numpy as np, cv2
from PIL import Image
from scipy import ndimage
from skimage.morphology import skeletonize
import shapely
from shapely.geometry import Polygon, LineString, Point, box

ROOT=os.path.dirname(os.path.abspath(__file__))


# ---- the world's shape (matching src/World.elm) ----

BMIN=np.array([-3.343595,-0.401627,-2.452917]); BMAX=np.array([4.236575,0.598373,1.992144])
R=0.198579
IMIN=BMIN+R; IMAX=BMAX-R
HX,HZ,WAIST,HF=1.156,-0.2058,0.47524,0.30432
RIM=WAIST+HF
def region(p):
    x,y,z=p
    if np.hypot(x-HX,z-HZ)<RIM-1e-4 and BMIN[1]+1e-3<y<BMAX[1]-1e-3: return 'hole'
    q=np.clip(p,IMIN,IMAX); d=p-q; n=(np.abs(d)>1e-4).sum()
    ax=[i for i in range(3) if abs(d[i])>1e-4]
    return {1:'face',2:'fillet',3:'corner'}.get(n,'inside')+''.join('xyz'[i]+('+' if d[i]>0 else '-') for i in ax)

# ---- charts ----

TOP,BOT=BMAX[1],BMIN[1]
# ---- slab chart: (x, t), t = arc length round the rounded-rectangle cross-section in (y, z)
yi0,yi1,zi0,zi1=IMIN[1],IMAX[1],IMIN[2],IMAX[2]
Lz=zi1-zi0; Ly=yi1-yi0; Q=R*np.pi/2
# segments in order, each: kind, length
SEGS=[('top',Lz),('f',(yi1,zi1, 0)),('zp',Ly),('f',(yi0,zi1,1)),('bot',Lz),('f',(yi0,zi0,2)),('zm',Ly),('f',(yi1,zi0,3))]
starts=[];acc=0
for s in SEGS:
    starts.append(acc); acc+= s[1] if not isinstance(s[1],tuple) else Q
PER=acc
# corner arcs: fillet k goes from direction d0 to d1 (in (y,z))
FDIR=[((1,0),(0,1)),((0,1),(-1,0)),((-1,0),(0,-1)),((0,-1),(1,0))]
SHIFT=starts[2]+Ly/2   # wrap at the middle of the +z side
def slab_t(y,z):
    # nearest segment by clamping to the inner rectangle
    cy=min(max(y,yi0),yi1); cz=min(max(z,zi0),zi1); dy=y-cy; dz=z-cz
    if abs(dy)>1e-6 and abs(dz)>1e-6:
        k={(1,1):1,(-1,1):3,(-1,-1):5,(1,-1):7}[(int(np.sign(dy)),int(np.sign(dz)))]
        (a0,a1)=FDIR[SEGS[k][1][2]]
        ang=np.arctan2(dy*a1[0]+dz*a1[1], dy*a0[0]+dz*a0[1])
        t=starts[k]+R*min(max(ang,0),np.pi/2)
    elif abs(dy)>=abs(dz) and dy>0 or (abs(dz)<=1e-6 and y>=yi1): t=starts[0]+(z-zi0)
    elif abs(dz)>abs(dy) and dz>0 or (abs(dy)<=1e-6 and z>=zi1): t=starts[2]+(yi1-y)
    elif dy<0 or y<=yi0: t=starts[4]+(zi1-z)
    else: t=starts[6]+(y-yi0)
    return (t-SHIFT)%PER
def slab_yz(t):
    t=(t+SHIFT)%PER
    for k in range(len(SEGS)-1,-1,-1):
        if t>=starts[k]: break
    s=t-starts[k]; kind=SEGS[k][0]
    if kind=='top': return TOP, zi0+s
    if kind=='zp': return yi1-s, BMAX[2]
    if kind=='bot': return BOT, zi1-s
    if kind=='zm': return yi0+s, BMIN[2]
    cy,cz,j=SEGS[k][1]; a0,a1=FDIR[j]; ang=s/R
    return cy+R*(np.cos(ang)*a0[0]+np.sin(ang)*a1[0]), cz+R*(np.cos(ang)*a0[1]+np.sin(ang)*a1[1])
def slab2d(p): return np.array([p[0], slab_t(p[1],p[2])])
def slab3d(q):
    y,z=slab_yz(q[1]); return np.array([q[0],y,z])
# ---- hole chart: (theta*R0, sigma*R0), sigma = integral ds/rho, 0 at the top rim, conformal
R0=WAIST
phis=np.linspace(0,np.pi/2,4001)
rho_arc=RIM-HF*np.sin(phis)
sig_arc=np.concatenate([[0],np.cumsum(HF/((rho_arc[1:]+rho_arc[:-1])/2)*np.diff(phis))])
S1=sig_arc[-1]; Lw=(TOP-HF)-(BOT+HF); S2=S1+Lw/WAIST; STOT=S2+S1
def hole_sigma(p):
    x,y,z=p; rho=np.hypot(x-HX,z-HZ)
    if y>=TOP-1e-6: return -np.log(max(rho,1e-9)/RIM)
    if y<=BOT+1e-6: return STOT+np.log(max(rho,1e-9)/RIM)
    if y>TOP-HF:  # top arc: centre (RIM, TOP-HF)
        phi=np.arctan2(RIM-rho, y-(TOP-HF)); return np.interp(min(max(phi,0),np.pi/2),phis,sig_arc)
    if y<BOT+HF:
        phi=np.arctan2(RIM-rho, (BOT+HF)-y); return STOT-np.interp(min(max(phi,0),np.pi/2),phis,sig_arc)
    return S1+((TOP-HF)-y)/WAIST
CUT=1.9  # angle round the hole with nothing painted on it
def hole2d(p):
    th=(np.arctan2(p[2]-HZ,p[0]-HX)-CUT)%(2*np.pi)-np.pi; return np.array([th*R0, hole_sigma(p)*R0])
def hole3d(q):
    th=q[0]/R0+np.pi+CUT; s=q[1]/R0
    if s<=0: rho=RIM*np.exp(-s); y=TOP
    elif s>=STOT: rho=RIM*np.exp(s-STOT); y=BOT
    elif s<S1: phi=np.interp(s,sig_arc,phis); rho=RIM-HF*np.sin(phi); y=TOP-HF+HF*np.cos(phi)
    elif s>S2: phi=np.interp(STOT-s,sig_arc,phis); rho=RIM-HF*np.sin(phi); y=BOT+HF-HF*np.cos(phi)
    else: rho=WAIST; y=(TOP-HF)-(s-S1)*WAIST
    return np.array([HX+rho*np.cos(th), y, HZ+rho*np.sin(th)])

# ---- drawing the textured model into a chart ----

src=open(os.path.join(ROOT,'src','ObjData.elm')).read()
V=[];T=[];F=[]
for line in src.split('\n'):
    p=line.split()
    if not p: continue
    if p[0]=='v': V.append([float(x) for x in p[1:4]])
    elif p[0]=='vt': T.append([float(x) for x in p[1:3]])
    elif p[0]=='f': F.append([tuple(int(i) for i in q.split('/')[:2]) for q in p[1:]])
V=np.array(V);T=np.array(T)
tex=np.array(Image.open(os.path.join(ROOT,'public','world.png')).convert('RGB'))
N=tex.shape[0]
RES=0.005
def rasterize(to2d, accept, lo, hi, wrap=None):
    W=int((hi[0]-lo[0])/RES)+1; H=int((hi[1]-lo[1])/RES)+1
    img=np.zeros((H,W,3),np.uint8); cov=np.zeros((H,W),bool)
    for f in F:
        P=[V[i-1] for i,_ in f]; UV=[T[j-1] for _,j in f]
        if not accept(P): continue
        Q=np.array([to2d(p) for p in P])
        if wrap is None and Q[:,1].max()-Q[:,1].min()>PER/2: continue
        if wrap is not None:
            for k in (1,2):
                while Q[k,0]-Q[0,0]>wrap/2: Q[k,0]-=wrap
                while Q[k,0]-Q[0,0]<-wrap/2: Q[k,0]+=wrap
        shifts=[0] if wrap is None else [-wrap,0,wrap]
        for sh in shifts:
            Qs=Q+np.array([sh,0])
            mn=np.floor((Qs.min(0)-lo)/RES).astype(int); mx=np.ceil((Qs.max(0)-lo)/RES).astype(int)
            mn=np.maximum(mn,0); mx=np.minimum(mx,[W-1,H-1])
            if (mx<mn).any(): continue
            xs,ys=np.meshgrid(np.arange(mn[0],mx[0]+1),np.arange(mn[1],mx[1]+1))
            pts=np.stack([xs.ravel()*RES+lo[0], ys.ravel()*RES+lo[1]],1)
            M=np.array([Qs[1]-Qs[0],Qs[2]-Qs[0]]).T
            if abs(np.linalg.det(M))<1e-12: continue
            L=np.linalg.solve(M,(pts-Qs[0]).T).T
            ins=(L[:,0]>=-1e-6)&(L[:,1]>=-1e-6)&(L.sum(1)<=1+1e-6)
            if not ins.any(): continue
            L=L[ins]; uv=UV[0]+L[:,:1]*(UV[1]-UV[0])+L[:,1:]*(UV[2]-UV[0])
            tx=np.clip((uv[:,0]*N).astype(int),0,N-1); ty=np.clip(N-1-(uv[:,1]*N).astype(int),0,N-1)
            gx=xs.ravel()[ins]; gy=ys.ravel()[ins]
            img[gy,gx]=tex[ty,tx]; cov[gy,gx]=True
    return img,cov
def is_slab(P):
    rs=[region(p) for p in P]
    return all(r in ('facey+','facey-','facez+','facez-','fillety+z+','fillety+z-','fillety-z+','fillety-z-') for r in rs)
def is_hole(P):
    rs=[region(p) for p in P]
    return any(r=='hole' for r in rs) or all(r in ('facey+','facey-') and np.hypot(p[0]-HX,p[2]-HZ)<RIM+0.35 for r,p in zip(rs,P))
SLO=np.array([BMIN[0],0.0]); SHI=np.array([BMAX[0],PER])
HLO=np.array([-np.pi*R0,-0.35]); HHI=np.array([np.pi*R0,STOT*R0+0.35])
# ---- tracing ----

def masks(img, cov):
    black=(img.sum(2)==0)&cov
    tan=(np.abs(img.astype(int)-[187,157,72]).sum(2)<30)&cov
    return black, tan

def remove_small(m, minsize):
    lab,n=ndimage.label(m, structure=np.ones((3,3)))
    sizes=ndimage.sum(m,lab,range(1,n+1))
    keep=np.zeros(n+1,bool); keep[1:]=sizes>=minsize
    return keep[lab]

NB=[(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
def trace(sk):
    H,W=sk.shape
    pts=set(zip(*np.nonzero(sk)))
    def nbrs(p):
        return [(p[0]+a,p[1]+b) for a,b in NB if (p[0]+a,p[1]+b) in pts]
    deg={p:len(nbrs(p)) for p in pts}
    nodes={p for p in pts if deg[p]!=2}
    used=set(); lines=[]
    def walk(start,nxt):
        line=[start,nxt]; used.add(frozenset((start,nxt)))
        prev,cur=start,nxt
        while cur not in nodes:
            cand=[q for q in nbrs(cur) if q!=prev and frozenset((cur,q)) not in used]
            if not cand: break
            # prefer 4-neighbours to avoid diagonal shortcuts in corners
            cand.sort(key=lambda q: abs(q[0]-cur[0])+abs(q[1]-cur[1]))
            q=cand[0]; used.add(frozenset((cur,q))); line.append(q); prev,cur=cur,q
            if cur==start: break
        return line
    for n in nodes:
        for q in nbrs(n):
            if frozenset((n,q)) not in used: lines.append(walk(n,q))
    for p in pts:  # loops without nodes
        for q in nbrs(p):
            if frozenset((p,q)) not in used: lines.append(walk(p,q))
    return lines, nodes

def rdp(P, eps):
    P=np.asarray(P,float)
    if len(P)<3: return P
    a,b=P[0],P[-1]; d=b-a; L=np.hypot(*d)
    if L<1e-12: dist=np.hypot(*(P-a).T)
    else: dist=np.abs(d[0]*(P[:,1]-a[1])-d[1]*(P[:,0]-a[0]))/L
    i=int(np.argmax(dist))
    if dist[i]>eps:
        return np.vstack([rdp(P[:i+1],eps)[:-1], rdp(P[i:],eps)])
    return np.array([a,b])

def walls(img,cov,lo):
    black,_=masks(img,cov)
    black=ndimage.binary_closing(black,np.ones((3,3)))
    black=remove_small(black,25)
    sk=skeletonize(black)
    lines,nodes=trace(sk)
    # drop short spurs ending in nothing
    out=[]
    for l in lines:
        length=sum(np.hypot(l[i+1][0]-l[i][0],l[i+1][1]-l[i][1]) for i in range(len(l)-1))
        if length*RES < 0.03: continue
        P=np.array([[c*RES+lo[0], r*RES+lo[1]] for r,c in l])
        out.append(rdp(P,0.006))
    return out

def areas(img,cov,lo):
    _,tan=masks(img,cov)
    tan=ndimage.binary_closing(tan,np.ones((5,5)))
    tan=remove_small(tan,200)
    tan=~remove_small(~tan,200)
    cs,hier=cv2.findContours(tan.astype(np.uint8),cv2.RETR_CCOMP,cv2.CHAIN_APPROX_NONE)
    polys=[]
    for i,c in enumerate(cs):
        if hier[0][i][3]!=-1: continue
        outer=cv2.approxPolyDP(c,1.2,True)[:,0,:]
        holes=[]; j=hier[0][i][2]
        while j!=-1:
            h=cv2.approxPolyDP(cs[j],1.2,True)[:,0,:]
            if len(h)>=3: holes.append(h)
            j=hier[0][j][0]
        tochart=lambda a: [(x*RES+lo[0], y*RES+lo[1]) for x,y in a]
        if len(outer)>=3: polys.append(Polygon(tochart(outer),[tochart(h) for h in holes]).buffer(0))
    return polys

# ---- clip to each chart's part of the surface, back to 3D ----

ttop=slab_t(TOP,HZ); tbot=slab_t(BOT,HZ)
slab_domain=box(IMIN[0],0,IMAX[0],PER).difference(Point(HX,ttop).buffer(RIM,256)).difference(Point(HX,tbot).buffer(RIM,256))
hole_domain=box(-np.pi*R0+1e-6,0,np.pi*R0-1e-6,STOT*R0)

def lines_of(g):
    if g.is_empty: return []
    if g.geom_type=='LineString': return [g]
    if hasattr(g,'geoms'): return [l for x in g.geoms for l in lines_of(x)]
    return []
def polys_of(g):
    if g.is_empty: return []
    if g.geom_type=='Polygon': return [g]
    if hasattr(g,'geoms'): return [p for x in g.geoms for p in polys_of(x)]
    return []

wall3d=[]; paving3d=[]
charts=[(rasterize(slab2d,is_slab,SLO,SHI),SLO,slab_domain,slab3d),
        (rasterize(hole2d,is_hole,HLO,HHI,wrap=2*np.pi*R0),HLO,hole_domain,hole3d)]
for (img,cov),lo,dom,to3d in charts:
    for l in walls(img,cov,lo):
        for part in lines_of(LineString(l).intersection(dom)):
            if part.length<0.02: continue
            wall3d.append([to3d(np.array(q)) for q in part.coords])
    for p in areas(img,cov,lo):
        for part in polys_of(p.intersection(dom)):
            if part.area<0.0005: continue
            part=shapely.segmentize(part.simplify(0.004),0.1)
            tris=polys_of(shapely.constrained_delaunay_triangles(part))
            pts=[]; index={}; T=[]
            for t in tris:
                ids=[]
                for q in list(t.exterior.coords)[:3]:
                    k=(round(q[0],7),round(q[1],7))
                    if k not in index: index[k]=len(pts); pts.append(to3d(np.array(q)))
                    ids.append(index[k])
                T.append(tuple(ids))
            paving3d.append((pts,T))

# join wall ends that meet (across the rim, and gaps in the painting)
def join(lines, tol):
    lines=[list(map(np.asarray,l)) for l in lines]
    changed=True
    while changed:
        changed=False
        for i in range(len(lines)):
            for j in range(i+1,len(lines)):
                a,b=lines[i],lines[j]
                for ra in (False,True):
                    for rb in (False,True):
                        A=a[::-1] if ra else a; B=b[::-1] if rb else b
                        if np.linalg.norm(A[-1]-B[0])<tol:
                            lines[i]=A+(B[1:] if np.linalg.norm(A[-1]-B[0])<1e-4 else B); del lines[j]; changed=True; break
                    if changed: break
                if changed: break
            if changed: break
    return lines
wall3d=join(wall3d,0.025)
print(len(wall3d),'walls',sum(len(w) for w in wall3d),'points;',len(paving3d),'pavings',sum(len(p) for p,_ in paving3d),'points',sum(len(t) for _,t in paving3d),'triangles')

# ---- write the Elm module ----

def f(x):
    s=f"{x:.3f}".rstrip('0').rstrip('.')
    if s in ('-0',''): s='0'
    return s
def pt(p): return f"( {f(p[0])}, {f(p[1])}, {f(p[2])} )"
def lst(items, indent):
    pad=' '*indent
    if not items: return pad+'[]'
    return pad+'[ '+('\n'+pad+', ').join(items)+'\n'+pad+']'
out=['''module WorldShapes exposing (pavings, walls)

{-| Shapes on the surface, drawn on the minimap in place of the texture: house walls as lines, and
paths and house floors as filled areas. Points are in meters in world coordinates, on or very near
the surface.

Made by `trace_shapes.py` from the texture (`public/world.png`), so they're only as good as
that tracing.

-}

import Shapes exposing (Paving)


walls : List (List ( Float, Float, Float ))
walls =''']
out.append(lst([ '[ '+', '.join(pt(p) for p in w)+' ]' for w in wall3d],4))
out.append('''

pavings : List Paving
pavings =''')
pv=[]
for pts,T in paving3d:
    pv.append('{ points =\n'+lst([pt(p) for p in pts],12)+'\n      , triangles =\n'+lst(['( '+', '.join(map(str,t))+' )' for t in T],12)+'\n      }')
out.append(lst(pv,4))
open(os.path.join(ROOT,'src','WorldShapes.elm'),'w').write('\n'.join(out)+'\n')