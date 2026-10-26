(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.fz.d5 === region.f_.d5)
	{
		return 'on line ' + region.fz.d5;
	}
	return 'on lines ' + region.fz.d5 + ' through ' + region.f_.d5;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.ia,
		impl.jB,
		impl.jf,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.it) { flags += 'm'; }
	if (options.hz) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr$ = function (func, baseCase, _v0) {
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (!node.$) {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
			} else {
				var values = node.a;
				return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
			}
		});
	return A3(
		$elm$core$Elm$JsArray$foldr,
		helper,
		A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
		tree);
};
var $elm$core$Array$foldr = F3($elm$core$Array$foldr$);
var $elm$core$Array$toList = function (array) {
	return $elm$core$Array$foldr$($elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr$ = function (func, acc, t) {
	foldr:
	while (true) {
		if (t.$ === -2) {
			return acc;
		} else {
			var key = t.b;
			var value = t.c;
			var left = t.d;
			var right = t.e;
			var $temp$acc = A3(
				func,
				key,
				value,
				$elm$core$Dict$foldr$(func, acc, right)),
				$temp$t = left;
			acc = $temp$acc;
			t = $temp$t;
			continue foldr;
		}
	}
};
var $elm$core$Dict$foldr = F3($elm$core$Dict$foldr$);
var $elm$core$Dict$toList = function (dict) {
	return $elm$core$Dict$foldr$(
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return $elm$core$Dict$foldr$(
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $author$project$MinimapWorker$DrawMinimap = $elm$core$Basics$identity;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure$ = function (a, b) {
	return {$: 3, a: a, b: b};
};
var $elm$json$Json$Decode$Failure = F2($elm$json$Json$Decode$Failure$);
var $elm$json$Json$Decode$Field$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $elm$json$Json$Decode$Field = F2($elm$json$Json$Decode$Field$);
var $elm$json$Json$Decode$Index$ = function (a, b) {
	return {$: 1, a: a, b: b};
};
var $elm$json$Json$Decode$Index = F2($elm$json$Json$Decode$Index$);
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join$ = function (sep, chunks) {
	return A2(
		_String_join,
		sep,
		_List_toArray(chunks));
};
var $elm$core$String$join = F2($elm$core$String$join$);
var $elm$core$String$split$ = function (sep, string) {
	return _List_fromArray(
		A2(_String_split, sep, string));
};
var $elm$core$String$split = F2($elm$core$String$split$);
var $elm$json$Json$Decode$indent = function (str) {
	return $elm$core$String$join$(
		'\n    ',
		$elm$core$String$split$('\n', str));
};
var $elm$core$List$foldl$ = function (func, acc, list) {
	foldl:
	while (true) {
		if (!list.b) {
			return acc;
		} else {
			var x = list.a;
			var xs = list.b;
			var $temp$acc = A2(func, x, acc),
				$temp$list = xs;
			acc = $temp$acc;
			list = $temp$list;
			continue foldl;
		}
	}
};
var $elm$core$List$foldl = F3($elm$core$List$foldl$);
var $elm$core$List$length = function (xs) {
	return $elm$core$List$foldl$(
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp$ = function (lo, hi, list) {
	rangeHelp:
	while (true) {
		if (_Utils_cmp(lo, hi) < 1) {
			var $temp$hi = hi - 1,
				$temp$list = A2($elm$core$List$cons, hi, list);
			hi = $temp$hi;
			list = $temp$list;
			continue rangeHelp;
		} else {
			return list;
		}
	}
};
var $elm$core$List$rangeHelp = F3($elm$core$List$rangeHelp$);
var $elm$core$List$range$ = function (lo, hi) {
	return $elm$core$List$rangeHelp$(lo, hi, _List_Nil);
};
var $elm$core$List$range = F2($elm$core$List$range$);
var $elm$core$List$indexedMap$ = function (f, xs) {
	return A3(
		$elm$core$List$map2,
		f,
		$elm$core$List$range$(
			0,
			$elm$core$List$length(xs) - 1),
		xs);
};
var $elm$core$List$indexedMap = F2($elm$core$List$indexedMap$);
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return $elm$core$List$foldl$($elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf$ = function (i, error) {
	return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
		$elm$json$Json$Decode$errorToString(error))));
};
var $elm$json$Json$Decode$errorOneOf = F2($elm$json$Json$Decode$errorOneOf$);
var $elm$json$Json$Decode$errorToString = function (error) {
	return $elm$json$Json$Decode$errorToStringHelp$(error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp$ = function (error, context) {
	errorToStringHelp:
	while (true) {
		switch (error.$) {
			case 0:
				var f = error.a;
				var err = error.b;
				var isSimple = function () {
					var _v1 = $elm$core$String$uncons(f);
					if (_v1.$ === 1) {
						return false;
					} else {
						var _v2 = _v1.a;
						var _char = _v2.a;
						var rest = _v2.b;
						return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
					}
				}();
				var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
				var $temp$error = err,
					$temp$context = A2($elm$core$List$cons, fieldName, context);
				error = $temp$error;
				context = $temp$context;
				continue errorToStringHelp;
			case 1:
				var i = error.a;
				var err = error.b;
				var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
				var $temp$error = err,
					$temp$context = A2($elm$core$List$cons, indexName, context);
				error = $temp$error;
				context = $temp$context;
				continue errorToStringHelp;
			case 2:
				var errors = error.a;
				if (!errors.b) {
					return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
						if (!context.b) {
							return '!';
						} else {
							return ' at json' + $elm$core$String$join$(
								'',
								$elm$core$List$reverse(context));
						}
					}();
				} else {
					if (!errors.b.b) {
						var err = errors.a;
						var $temp$error = err;
						error = $temp$error;
						continue errorToStringHelp;
					} else {
						var starter = function () {
							if (!context.b) {
								return 'Json.Decode.oneOf';
							} else {
								return 'The Json.Decode.oneOf at json' + $elm$core$String$join$(
									'',
									$elm$core$List$reverse(context));
							}
						}();
						var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
							$elm$core$List$length(errors)) + ' ways:'));
						return $elm$core$String$join$(
							'\n\n',
							A2(
								$elm$core$List$cons,
								introduction,
								$elm$core$List$indexedMap$($elm$json$Json$Decode$errorOneOf, errors)));
					}
				}
			default:
				var msg = error.a;
				var json = error.b;
				var introduction = function () {
					if (!context.b) {
						return 'Problem with the given value:\n\n';
					} else {
						return 'Problem with the value at json' + ($elm$core$String$join$(
							'',
							$elm$core$List$reverse(context)) + ':\n\n    ');
					}
				}();
				return introduction + ($elm$json$Json$Decode$indent(
					A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
		}
	}
};
var $elm$json$Json$Decode$errorToStringHelp = F2($elm$json$Json$Decode$errorToStringHelp$);
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin$ = function (a, b, c, d) {
	return {$: 0, a: a, b: b, c: c, d: d};
};
var $elm$core$Array$Array_elm_builtin = F4($elm$core$Array$Array_elm_builtin$);
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase$ = function (base, number) {
	return _Basics_log(number) / _Basics_log(base);
};
var $elm$core$Basics$logBase = F2($elm$core$Basics$logBase$);
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	$elm$core$Basics$logBase$(2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = $elm$core$Array$Array_elm_builtin$(0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL$ = function (f, x) {
	return f(x);
};
var $elm$core$Basics$apL = F2($elm$core$Basics$apL$);
var $elm$core$Basics$apR$ = function (x, f) {
	return f(x);
};
var $elm$core$Basics$apR = F2($elm$core$Basics$apR$);
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max$ = function (x, y) {
	return (_Utils_cmp(x, y) > 0) ? x : y;
};
var $elm$core$Basics$max = F2($elm$core$Basics$max$);
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes$ = function (nodes, acc) {
	compressNodes:
	while (true) {
		var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
		var node = _v0.a;
		var remainingNodes = _v0.b;
		var newAcc = A2(
			$elm$core$List$cons,
			$elm$core$Array$SubTree(node),
			acc);
		if (!remainingNodes.b) {
			return $elm$core$List$reverse(newAcc);
		} else {
			var $temp$nodes = remainingNodes,
				$temp$acc = newAcc;
			nodes = $temp$nodes;
			acc = $temp$acc;
			continue compressNodes;
		}
	}
};
var $elm$core$Array$compressNodes = F2($elm$core$Array$compressNodes$);
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder$ = function (nodeList, nodeListSize) {
	treeFromBuilder:
	while (true) {
		var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
		if (newNodeSize === 1) {
			return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
		} else {
			var $temp$nodeList = $elm$core$Array$compressNodes$(nodeList, _List_Nil),
				$temp$nodeListSize = newNodeSize;
			nodeList = $temp$nodeList;
			nodeListSize = $temp$nodeListSize;
			continue treeFromBuilder;
		}
	}
};
var $elm$core$Array$treeFromBuilder = F2($elm$core$Array$treeFromBuilder$);
var $elm$core$Array$builderToArray$ = function (reverseNodeList, builder) {
	if (!builder.G) {
		return $elm$core$Array$Array_elm_builtin$(
			$elm$core$Elm$JsArray$length(builder.M),
			$elm$core$Array$shiftStep,
			$elm$core$Elm$JsArray$empty,
			builder.M);
	} else {
		var treeLen = builder.G * $elm$core$Array$branchFactor;
		var depth = $elm$core$Basics$floor(
			$elm$core$Basics$logBase$($elm$core$Array$branchFactor, treeLen - 1));
		var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.Q) : builder.Q;
		var tree = $elm$core$Array$treeFromBuilder$(correctNodeList, builder.G);
		return $elm$core$Array$Array_elm_builtin$(
			$elm$core$Elm$JsArray$length(builder.M) + treeLen,
			$elm$core$Basics$max$(5, depth * $elm$core$Array$shiftStep),
			tree,
			builder.M);
	}
};
var $elm$core$Array$builderToArray = F2($elm$core$Array$builderToArray$);
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp$ = function (fn, fromIndex, len, nodeList, tail) {
	initializeHelp:
	while (true) {
		if (fromIndex < 0) {
			return $elm$core$Array$builderToArray$(
				false,
				{Q: nodeList, G: (len / $elm$core$Array$branchFactor) | 0, M: tail});
		} else {
			var leaf = $elm$core$Array$Leaf(
				A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
			var $temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
				$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList);
			fromIndex = $temp$fromIndex;
			nodeList = $temp$nodeList;
			continue initializeHelp;
		}
	}
};
var $elm$core$Array$initializeHelp = F5($elm$core$Array$initializeHelp$);
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize$ = function (len, fn) {
	if (len <= 0) {
		return $elm$core$Array$empty;
	} else {
		var tailLen = len % $elm$core$Array$branchFactor;
		var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
		var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
		return $elm$core$Array$initializeHelp$(fn, initialFromIndex, len, _List_Nil, tail);
	}
};
var $elm$core$Array$initialize = F2($elm$core$Array$initialize$);
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $author$project$MinimapWorker$drawMinimap = _Platform_incomingPort('drawMinimap', $elm$json$Json$Decode$value);
var $author$project$Shapes$empty = {
	bU: {V: $elm$core$Array$empty, b_: 0, bD: 0, bE: 0, cc: 0, cd: 0, ce: 0},
	iM: _List_Nil,
	fn: $elm$core$Array$empty,
	jE: _List_Nil
};
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $author$project$WorldShapes$pavings = _List_fromArray(
	[
		{
		fn: _List_fromArray(
			[
				_Utils_Tuple3(1.051, 0.598, -1.102),
				_Utils_Tuple3(0.981, 0.598, -1.137),
				_Utils_Tuple3(0.976, 0.598, -1.127),
				_Utils_Tuple3(0.851, 0.598, -1.127),
				_Utils_Tuple3(0.916, 0.598, -1.132),
				_Utils_Tuple3(0.856, 0.598, -1.137),
				_Utils_Tuple3(0.768, 0.598, -0.882),
				_Utils_Tuple3(0.763, 0.598, -1.125),
				_Utils_Tuple3(0.674, 0.598, -1.122),
				_Utils_Tuple3(0.496, 0.598, -1.077),
				_Utils_Tuple3(0.496, 0.598, -1.117),
				_Utils_Tuple3(0.486, 0.598, -1.102),
				_Utils_Tuple3(0.486, 0.598, -1.082),
				_Utils_Tuple3(0.496, 0.598, -0.872),
				_Utils_Tuple3(0.486, 0.598, -0.867),
				_Utils_Tuple3(0.486, 0.598, -0.822),
				_Utils_Tuple3(0.471, 0.598, -0.812),
				_Utils_Tuple3(0.486, 0.598, -0.782),
				_Utils_Tuple3(0.431, 0.598, -0.742),
				_Utils_Tuple3(0.461, 0.598, -0.762),
				_Utils_Tuple3(0.446, 0.598, -0.767),
				_Utils_Tuple3(0.381, 0.598, -0.722),
				_Utils_Tuple3(0.371, 0.598, -0.702),
				_Utils_Tuple3(0.271, 0.598, -0.717),
				_Utils_Tuple3(0.326, 0.598, -0.722),
				_Utils_Tuple3(0.341, 0.598, -0.742),
				_Utils_Tuple3(0.366, 0.598, -0.742),
				_Utils_Tuple3(0.391, 0.598, -0.777),
				_Utils_Tuple3(0.406, 0.598, -0.777),
				_Utils_Tuple3(0.411, 0.598, -0.792),
				_Utils_Tuple3(0.436, 0.598, -0.807),
				_Utils_Tuple3(0.441, 0.598, -0.852),
				_Utils_Tuple3(0.456, 0.598, -0.857),
				_Utils_Tuple3(0.456, 0.598, -0.917),
				_Utils_Tuple3(0.456, 0.598, -0.972),
				_Utils_Tuple3(0.466, 0.598, -0.922),
				_Utils_Tuple3(0.466, 0.598, -0.967),
				_Utils_Tuple3(0.456, 0.598, -1.032),
				_Utils_Tuple3(0.456, 0.598, -1.092),
				_Utils_Tuple3(0.446, 0.598, -1.102),
				_Utils_Tuple3(0.386, 0.598, -1.102),
				_Utils_Tuple3(0.326, 0.598, -1.102),
				_Utils_Tuple3(0.321, 0.598, -1.092),
				_Utils_Tuple3(0.185, 0.598, -1.092),
				_Utils_Tuple3(0.116, 0.598, -1.092),
				_Utils_Tuple3(0.111, 0.598, -1.077),
				_Utils_Tuple3(0.041, 0.598, -1.077),
				_Utils_Tuple3(0.036, 0.598, -1.067),
				_Utils_Tuple3(0.016, 0.598, -1.042),
				_Utils_Tuple3(0.006, 0.598, -1.067),
				_Utils_Tuple3(0.001, 0.598, -1.047),
				_Utils_Tuple3(0.016, 0.598, -0.947),
				_Utils_Tuple3(0.001, 0.598, -0.942),
				_Utils_Tuple3(0.001, 0.598, -0.861),
				_Utils_Tuple3(0.001, 0.598, -0.779),
				_Utils_Tuple3(0.001, 0.598, -0.697),
				_Utils_Tuple3(0.096, 0.598, -0.697),
				_Utils_Tuple3(0.001, 0.598, -0.597),
				_Utils_Tuple3(0.051, 0.598, -0.66),
				_Utils_Tuple3(0.001, 0.598, -0.657),
				_Utils_Tuple3(0.001, 0.598, -0.537),
				_Utils_Tuple3(-0.009, 0.598, -0.532),
				_Utils_Tuple3(-0.009, 0.598, -0.464),
				_Utils_Tuple3(-0.009, 0.598, -0.396),
				_Utils_Tuple3(-0.009, 0.598, -0.327),
				_Utils_Tuple3(0.001, 0.598, -0.322),
				_Utils_Tuple3(0.001, 0.598, -0.277),
				_Utils_Tuple3(0.011, 0.598, -0.277),
				_Utils_Tuple3(0.026, 0.598, -0.252),
				_Utils_Tuple3(0.099, 0.598, -0.252),
				_Utils_Tuple3(0.171, 0.598, -0.252),
				_Utils_Tuple3(0.176, 0.598, -0.237),
				_Utils_Tuple3(0.243, 0.598, -0.239),
				_Utils_Tuple3(0.31, 0.598, -0.24),
				_Utils_Tuple3(0.377, 0.598, -0.241),
				_Utils_Tuple3(0.384, 0.598, -0.299),
				_Utils_Tuple3(0.496, 0.598, -0.737),
				_Utils_Tuple3(0.533, 0.598, -0.674),
				_Utils_Tuple3(0.506, 0.598, -0.747),
				_Utils_Tuple3(1.051, 0.598, -1.032),
				_Utils_Tuple3(1.063, 0.598, -0.98),
				_Utils_Tuple3(1.061, 0.598, -1.027),
				_Utils_Tuple3(1.061, 0.598, -1.107),
				_Utils_Tuple3(1.061, 0.598, -1.127),
				_Utils_Tuple3(1.051, 0.598, -1.137),
				_Utils_Tuple3(0.911, 0.598, -0.946),
				_Utils_Tuple3(0.496, 0.598, -1.009),
				_Utils_Tuple3(0.585, 0.598, -1.12),
				_Utils_Tuple3(0.506, 0.598, -0.772),
				_Utils_Tuple3(0.471, 0.598, -0.737),
				_Utils_Tuple3(0.253, 0.598, -1.092),
				_Utils_Tuple3(0.101, 0.598, -0.662),
				_Utils_Tuple3(0.391, 0.598, -0.358),
				_Utils_Tuple3(0.987, 0.598, -0.963),
				_Utils_Tuple3(0.84, 0.598, -0.914),
				_Utils_Tuple3(0.64, 0.598, -0.79),
				_Utils_Tuple3(0.501, 0.598, -0.624),
				_Utils_Tuple3(0.407, 0.598, -0.413),
				_Utils_Tuple3(0.496, 0.598, -0.941),
				_Utils_Tuple3(0.468, 0.598, -0.573),
				_Utils_Tuple3(0.704, 0.598, -0.836),
				_Utils_Tuple3(0.422, 0.598, -0.468),
				_Utils_Tuple3(0.276, 0.598, -0.692),
				_Utils_Tuple3(0.326, 0.598, -0.692),
				_Utils_Tuple3(0.445, 0.598, -0.521),
				_Utils_Tuple3(0.586, 0.598, -0.732)
			]),
		aJ: _List_fromArray(
			[
				_Utils_Tuple3(0, 1, 2),
				_Utils_Tuple3(3, 4, 5),
				_Utils_Tuple3(6, 7, 8),
				_Utils_Tuple3(9, 10, 11),
				_Utils_Tuple3(11, 12, 9),
				_Utils_Tuple3(13, 14, 15),
				_Utils_Tuple3(15, 16, 17),
				_Utils_Tuple3(18, 19, 20),
				_Utils_Tuple3(18, 21, 22),
				_Utils_Tuple3(23, 24, 25),
				_Utils_Tuple3(25, 26, 27),
				_Utils_Tuple3(27, 28, 29),
				_Utils_Tuple3(29, 30, 31),
				_Utils_Tuple3(31, 32, 33),
				_Utils_Tuple3(34, 35, 36),
				_Utils_Tuple3(37, 38, 39),
				_Utils_Tuple3(40, 41, 42),
				_Utils_Tuple3(43, 44, 45),
				_Utils_Tuple3(45, 46, 47),
				_Utils_Tuple3(48, 49, 50),
				_Utils_Tuple3(51, 52, 53),
				_Utils_Tuple3(54, 55, 56),
				_Utils_Tuple3(57, 58, 59),
				_Utils_Tuple3(60, 61, 62),
				_Utils_Tuple3(63, 64, 65),
				_Utils_Tuple3(65, 66, 67),
				_Utils_Tuple3(67, 68, 69),
				_Utils_Tuple3(70, 71, 72),
				_Utils_Tuple3(73, 74, 75),
				_Utils_Tuple3(76, 77, 78),
				_Utils_Tuple3(79, 80, 81),
				_Utils_Tuple3(0, 82, 83),
				_Utils_Tuple3(1, 0, 84),
				_Utils_Tuple3(85, 4, 3),
				_Utils_Tuple3(86, 8, 87),
				_Utils_Tuple3(10, 9, 87),
				_Utils_Tuple3(88, 15, 17),
				_Utils_Tuple3(19, 18, 89),
				_Utils_Tuple3(90, 27, 31),
				_Utils_Tuple3(27, 29, 31),
				_Utils_Tuple3(35, 34, 33),
				_Utils_Tuple3(40, 37, 39),
				_Utils_Tuple3(37, 40, 42),
				_Utils_Tuple3(51, 43, 45),
				_Utils_Tuple3(49, 48, 47),
				_Utils_Tuple3(56, 53, 54),
				_Utils_Tuple3(58, 57, 91),
				_Utils_Tuple3(70, 62, 63),
				_Utils_Tuple3(69, 65, 67),
				_Utils_Tuple3(63, 69, 70),
				_Utils_Tuple3(92, 72, 73),
				_Utils_Tuple3(73, 75, 92),
				_Utils_Tuple3(80, 79, 93),
				_Utils_Tuple3(84, 0, 83),
				_Utils_Tuple3(94, 3, 7),
				_Utils_Tuple3(87, 9, 86),
				_Utils_Tuple3(95, 15, 88),
				_Utils_Tuple3(96, 18, 22),
				_Utils_Tuple3(90, 31, 33),
				_Utils_Tuple3(42, 33, 34),
				_Utils_Tuple3(37, 42, 34),
				_Utils_Tuple3(23, 90, 43),
				_Utils_Tuple3(47, 48, 45),
				_Utils_Tuple3(23, 53, 56),
				_Utils_Tuple3(91, 57, 60),
				_Utils_Tuple3(69, 63, 65),
				_Utils_Tuple3(72, 92, 70),
				_Utils_Tuple3(70, 92, 97),
				_Utils_Tuple3(2, 93, 79),
				_Utils_Tuple3(79, 0, 2),
				_Utils_Tuple3(98, 8, 86),
				_Utils_Tuple3(15, 95, 13),
				_Utils_Tuple3(96, 22, 99),
				_Utils_Tuple3(90, 25, 27),
				_Utils_Tuple3(33, 42, 90),
				_Utils_Tuple3(45, 48, 51),
				_Utils_Tuple3(97, 60, 62),
				_Utils_Tuple3(60, 97, 91),
				_Utils_Tuple3(4, 93, 2),
				_Utils_Tuple3(93, 4, 85),
				_Utils_Tuple3(100, 13, 95),
				_Utils_Tuple3(90, 23, 25),
				_Utils_Tuple3(53, 23, 51),
				_Utils_Tuple3(97, 62, 70),
				_Utils_Tuple3(85, 3, 94),
				_Utils_Tuple3(13, 100, 98),
				_Utils_Tuple3(43, 51, 23),
				_Utils_Tuple3(23, 56, 91),
				_Utils_Tuple3(91, 97, 101),
				_Utils_Tuple3(7, 6, 94),
				_Utils_Tuple3(23, 91, 102),
				_Utils_Tuple3(103, 101, 104),
				_Utils_Tuple3(8, 100, 6),
				_Utils_Tuple3(101, 102, 91),
				_Utils_Tuple3(103, 104, 99),
				_Utils_Tuple3(98, 100, 8),
				_Utils_Tuple3(101, 103, 102),
				_Utils_Tuple3(105, 95, 88),
				_Utils_Tuple3(22, 103, 99),
				_Utils_Tuple3(78, 105, 88),
				_Utils_Tuple3(18, 96, 89),
				_Utils_Tuple3(105, 78, 77),
				_Utils_Tuple3(77, 89, 96),
				_Utils_Tuple3(89, 77, 76)
			])
	},
		{
		fn: _List_fromArray(
			[
				_Utils_Tuple3(1.416, -0.402, -0.958),
				_Utils_Tuple3(1.416, -0.402, -0.978),
				_Utils_Tuple3(1.431, -0.402, -0.988),
				_Utils_Tuple3(1.441, -0.402, -1.028),
				_Utils_Tuple3(1.451, -0.402, -1.028),
				_Utils_Tuple3(1.466, -0.402, -1.043),
				_Utils_Tuple3(1.466, -0.402, -1.063),
				_Utils_Tuple3(1.481, -0.402, -1.068),
				_Utils_Tuple3(1.481, -0.402, -1.098),
				_Utils_Tuple3(1.491, -0.402, -1.103),
				_Utils_Tuple3(1.491, -0.402, -1.123),
				_Utils_Tuple3(1.506, -0.402, -1.128),
				_Utils_Tuple3(1.516, -0.402, -1.183),
				_Utils_Tuple3(1.526, -0.402, -1.183),
				_Utils_Tuple3(1.531, -0.402, -1.208),
				_Utils_Tuple3(1.546, -0.402, -1.213),
				_Utils_Tuple3(1.556, -0.402, -1.258),
				_Utils_Tuple3(1.571, -0.402, -1.263),
				_Utils_Tuple3(1.581, -0.402, -1.318),
				_Utils_Tuple3(1.596, -0.402, -1.323),
				_Utils_Tuple3(1.601, -0.402, -1.376),
				_Utils_Tuple3(1.606, -0.402, -1.428),
				_Utils_Tuple3(1.621, -0.402, -1.433),
				_Utils_Tuple3(1.621, -0.402, -1.493),
				_Utils_Tuple3(1.631, -0.402, -1.498),
				_Utils_Tuple3(1.631, -0.402, -1.593),
				_Utils_Tuple3(1.646, -0.402, -1.598),
				_Utils_Tuple3(1.681, -0.393, -2.311),
				_Utils_Tuple3(1.871, -0.399, -2.288),
				_Utils_Tuple3(1.681, -0.402, -2.243),
				_Utils_Tuple3(1.641, -0.402, -1.853),
				_Utils_Tuple3(1.631, -0.402, -1.858),
				_Utils_Tuple3(1.636, -0.402, -1.918),
				_Utils_Tuple3(1.641, -0.402, -1.978),
				_Utils_Tuple3(1.631, -0.402, -1.983),
				_Utils_Tuple3(1.631, -0.402, -2.053),
				_Utils_Tuple3(1.641, -0.402, -2.058),
				_Utils_Tuple3(1.641, -0.402, -2.088),
				_Utils_Tuple3(1.656, -0.402, -2.093),
				_Utils_Tuple3(1.656, -0.402, -2.113),
				_Utils_Tuple3(1.666, -0.402, -2.118),
				_Utils_Tuple3(1.666, -0.402, -2.178),
				_Utils_Tuple3(1.666, -0.402, -2.238),
				_Utils_Tuple3(1.681, -0.314, -2.419),
				_Utils_Tuple3(1.666, -0.31, -2.422),
				_Utils_Tuple3(1.666, -0.275, -2.44),
				_Utils_Tuple3(1.656, -0.27, -2.441),
				_Utils_Tuple3(1.656, -0.201, -2.453),
				_Utils_Tuple3(1.641, -0.196, -2.453),
				_Utils_Tuple3(1.638, -0.12, -2.453),
				_Utils_Tuple3(1.606, 0.231, -2.453),
				_Utils_Tuple3(1.843, 0.219, -2.453),
				_Utils_Tuple3(1.616, 0.164, -2.453),
				_Utils_Tuple3(1.631, 0.034, -2.453),
				_Utils_Tuple3(1.616, 0.039, -2.453),
				_Utils_Tuple3(1.616, 0.101, -2.453),
				_Utils_Tuple3(1.606, 0.169, -2.453),
				_Utils_Tuple3(1.606, 0.294, -2.453),
				_Utils_Tuple3(1.591, 0.299, -2.453),
				_Utils_Tuple3(1.591, 0.389, -2.453),
				_Utils_Tuple3(1.591, 0.549, -2.385),
				_Utils_Tuple3(1.581, 0.552, -2.381),
				_Utils_Tuple3(1.581, 0.579, -2.339),
				_Utils_Tuple3(1.581, 0.595, -2.292),
				_Utils_Tuple3(1.566, 0.596, -2.287),
				_Utils_Tuple3(1.563, 0.598, -2.216),
				_Utils_Tuple3(1.808, 0.598, -2.046),
				_Utils_Tuple3(1.543, 0.598, -1.978),
				_Utils_Tuple3(1.806, 0.598, -1.962),
				_Utils_Tuple3(1.556, 0.598, -2.072),
				_Utils_Tuple3(1.541, 0.598, -2.067),
				_Utils_Tuple3(1.549, 0.598, -1.445),
				_Utils_Tuple3(1.821, 0.598, -1.492),
				_Utils_Tuple3(1.548, 0.598, -1.534),
				_Utils_Tuple3(1.551, 0.598, -1.267),
				_Utils_Tuple3(1.806, 0.598, -1.287),
				_Utils_Tuple3(1.55, 0.598, -1.356),
				_Utils_Tuple3(1.801, 0.598, -1.215),
				_Utils_Tuple3(1.781, 0.598, -1.137),
				_Utils_Tuple3(1.516, 0.598, -1.142),
				_Utils_Tuple3(1.526, 0.598, -1.202),
				_Utils_Tuple3(1.536, 0.598, -1.262),
				_Utils_Tuple3(1.501, 0.598, -1.137),
				_Utils_Tuple3(1.491, 0.598, -1.082),
				_Utils_Tuple3(1.476, 0.598, -1.077),
				_Utils_Tuple3(1.466, 0.598, -1.007),
				_Utils_Tuple3(1.451, 0.598, -1.002),
				_Utils_Tuple3(1.441, 0.598, -0.947),
				_Utils_Tuple3(1.426, 0.598, -0.937),
				_Utils_Tuple3(1.483, 0.598, -0.911),
				_Utils_Tuple3(1.656, 0.598, -0.822),
				_Utils_Tuple3(1.592, 0.598, -0.849),
				_Utils_Tuple3(1.644, 0.598, -0.813),
				_Utils_Tuple3(1.666, 0.598, -0.867),
				_Utils_Tuple3(1.686, 0.598, -0.882),
				_Utils_Tuple3(1.706, 0.598, -0.882),
				_Utils_Tuple3(1.716, 0.598, -0.917),
				_Utils_Tuple3(1.731, 0.598, -0.922),
				_Utils_Tuple3(1.731, 0.598, -0.942),
				_Utils_Tuple3(1.741, 0.598, -0.947),
				_Utils_Tuple3(1.741, 0.598, -0.977),
				_Utils_Tuple3(1.756, 0.598, -0.982),
				_Utils_Tuple3(1.756, 0.598, -1.027),
				_Utils_Tuple3(1.771, 0.598, -1.042),
				_Utils_Tuple3(1.796, 0.598, -1.142),
				_Utils_Tuple3(1.821, 0.598, -1.292),
				_Utils_Tuple3(1.821, 0.598, -1.359),
				_Utils_Tuple3(1.881, 0.598, -1.492),
				_Utils_Tuple3(1.886, 0.598, -1.477),
				_Utils_Tuple3(1.906, 0.598, -1.477),
				_Utils_Tuple3(1.931, 0.598, -1.492),
				_Utils_Tuple3(1.936, 0.598, -1.477),
				_Utils_Tuple3(1.981, 0.598, -1.477),
				_Utils_Tuple3(2.006, 0.598, -1.492),
				_Utils_Tuple3(2.011, 0.598, -1.477),
				_Utils_Tuple3(2.036, 0.598, -1.462),
				_Utils_Tuple3(2.036, 0.598, -1.417),
				_Utils_Tuple3(2.021, 0.598, -1.412),
				_Utils_Tuple3(2.021, 0.598, -1.315),
				_Utils_Tuple3(2.021, 0.598, -1.217),
				_Utils_Tuple3(2.036, 0.598, -1.212),
				_Utils_Tuple3(2.086, 0.598, -0.997),
				_Utils_Tuple3(2.033, 0.598, -1.069),
				_Utils_Tuple3(2.031, 0.598, -0.997),
				_Utils_Tuple3(2.091, 0.598, -0.982),
				_Utils_Tuple3(2.191, 0.598, -0.982),
				_Utils_Tuple3(2.676, 0.598, -1.057),
				_Utils_Tuple3(2.691, 0.598, -0.982),
				_Utils_Tuple3(2.691, 0.598, -1.052),
				_Utils_Tuple3(2.676, 0.598, -1.112),
				_Utils_Tuple3(2.691, 0.598, -1.117),
				_Utils_Tuple3(2.691, 0.598, -1.184),
				_Utils_Tuple3(2.586, 0.598, -1.647),
				_Utils_Tuple3(2.711, 0.598, -1.497),
				_Utils_Tuple3(2.696, 0.598, -1.552),
				_Utils_Tuple3(2.711, 0.598, -1.547),
				_Utils_Tuple3(2.696, 0.598, -1.647),
				_Utils_Tuple3(2.686, 0.598, -1.657),
				_Utils_Tuple3(2.591, 0.598, -1.657),
				_Utils_Tuple3(2.701, 0.598, -1.382),
				_Utils_Tuple3(2.491, 0.598, -1.649),
				_Utils_Tuple3(2.395, 0.598, -1.651),
				_Utils_Tuple3(2.203, 0.598, -1.654),
				_Utils_Tuple3(2.107, 0.598, -1.656),
				_Utils_Tuple3(2.011, 0.598, -1.657),
				_Utils_Tuple3(2.006, 0.598, -1.672),
				_Utils_Tuple3(1.991, 0.598, -1.677),
				_Utils_Tuple3(1.966, 0.598, -1.697),
				_Utils_Tuple3(1.991, 0.598, -1.697),
				_Utils_Tuple3(1.981, 0.598, -1.707),
				_Utils_Tuple3(1.821, 0.598, -1.872),
				_Utils_Tuple3(1.821, 0.598, -1.957),
				_Utils_Tuple3(1.871, -0.256, -2.446),
				_Utils_Tuple3(1.811, 0.594, -2.297),
				_Utils_Tuple3(1.821, 0.593, -2.302),
				_Utils_Tuple3(1.821, 0.557, -2.376),
				_Utils_Tuple3(1.821, 0.414, -2.452),
				_Utils_Tuple3(1.836, 0.409, -2.453),
				_Utils_Tuple3(1.84, 0.314, -2.453),
				_Utils_Tuple3(1.846, 0.124, -2.453),
				_Utils_Tuple3(1.861, 0.119, -2.453),
				_Utils_Tuple3(1.861, 0.056, -2.453),
				_Utils_Tuple3(1.861, -0.006, -2.453),
				_Utils_Tuple3(1.871, -0.011, -2.453),
				_Utils_Tuple3(1.871, -0.093, -2.453),
				_Utils_Tuple3(1.886, -0.26, -2.444),
				_Utils_Tuple3(1.886, -0.302, -2.427),
				_Utils_Tuple3(1.896, -0.306, -2.424),
				_Utils_Tuple3(1.886, -0.31, -2.422),
				_Utils_Tuple3(1.886, -0.367, -2.366),
				_Utils_Tuple3(1.886, -0.398, -2.293),
				_Utils_Tuple3(1.871, -0.402, -2.183),
				_Utils_Tuple3(1.886, -0.402, -2.178),
				_Utils_Tuple3(1.886, -0.402, -2.092),
				_Utils_Tuple3(1.886, -0.402, -1.66),
				_Utils_Tuple3(1.886, -0.402, -1.573),
				_Utils_Tuple3(1.876, -0.402, -1.568),
				_Utils_Tuple3(1.876, -0.402, -1.473),
				_Utils_Tuple3(1.861, -0.402, -1.468),
				_Utils_Tuple3(1.861, -0.402, -1.423),
				_Utils_Tuple3(1.851, -0.402, -1.418),
				_Utils_Tuple3(1.846, -0.402, -1.373),
				_Utils_Tuple3(1.836, -0.402, -1.368),
				_Utils_Tuple3(1.836, -0.402, -1.313),
				_Utils_Tuple3(1.821, -0.402, -1.308),
				_Utils_Tuple3(1.821, -0.402, -1.263),
				_Utils_Tuple3(1.811, -0.402, -1.258),
				_Utils_Tuple3(1.811, -0.402, -1.243),
				_Utils_Tuple3(1.796, -0.402, -1.238),
				_Utils_Tuple3(1.796, -0.402, -1.203),
				_Utils_Tuple3(1.781, -0.402, -1.198),
				_Utils_Tuple3(1.771, -0.402, -1.158),
				_Utils_Tuple3(1.756, -0.402, -1.153),
				_Utils_Tuple3(1.756, -0.402, -1.133),
				_Utils_Tuple3(1.736, -0.402, -1.103),
				_Utils_Tuple3(1.736, -0.402, -1.068),
				_Utils_Tuple3(1.721, -0.402, -1.063),
				_Utils_Tuple3(1.711, -0.402, -1.018),
				_Utils_Tuple3(1.696, -0.402, -1.013),
				_Utils_Tuple3(1.686, -0.402, -0.968),
				_Utils_Tuple3(1.671, -0.402, -0.963),
				_Utils_Tuple3(1.671, -0.402, -0.943),
				_Utils_Tuple3(1.651, -0.402, -0.923),
				_Utils_Tuple3(1.651, -0.402, -0.903),
				_Utils_Tuple3(1.641, -0.402, -0.903),
				_Utils_Tuple3(1.636, -0.402, -0.878),
				_Utils_Tuple3(1.611, -0.402, -0.863),
				_Utils_Tuple3(1.608, -0.402, -0.841),
				_Utils_Tuple3(1.559, -0.402, -0.871),
				_Utils_Tuple3(1.458, -0.402, -0.922),
				_Utils_Tuple3(1.406, -0.402, -0.944),
				_Utils_Tuple3(1.511, -0.402, -0.9),
				_Utils_Tuple3(1.871, -0.402, -2.236),
				_Utils_Tuple3(1.871, -0.175, -2.453),
				_Utils_Tuple3(1.591, 0.477, -2.437),
				_Utils_Tuple3(1.545, 0.598, -1.801),
				_Utils_Tuple3(1.544, 0.598, -1.89),
				_Utils_Tuple3(1.821, 0.598, -1.702),
				_Utils_Tuple3(1.547, 0.598, -1.623),
				_Utils_Tuple3(1.54, 0.598, -0.884),
				_Utils_Tuple3(1.821, 0.598, -1.426),
				_Utils_Tuple3(1.911, 0.598, -1.492),
				_Utils_Tuple3(1.986, 0.598, -1.492),
				_Utils_Tuple3(2.391, 0.598, -0.982),
				_Utils_Tuple3(2.035, 0.598, -1.141),
				_Utils_Tuple3(2.291, 0.598, -0.982),
				_Utils_Tuple3(2.591, 0.598, -0.982),
				_Utils_Tuple3(2.491, 0.598, -0.982),
				_Utils_Tuple3(2.691, 0.598, -1.251),
				_Utils_Tuple3(2.711, 0.598, -1.447),
				_Utils_Tuple3(2.299, 0.598, -1.652),
				_Utils_Tuple3(1.821, 0.493, -2.43),
				_Utils_Tuple3(1.886, -0.402, -1.832),
				_Utils_Tuple3(1.643, -0.402, -1.768),
				_Utils_Tuple3(1.886, -0.402, -2.005),
				_Utils_Tuple3(1.81, 0.598, -2.214),
				_Utils_Tuple3(1.56, 0.598, -2.144),
				_Utils_Tuple3(1.809, 0.598, -2.13),
				_Utils_Tuple3(1.821, 0.598, -1.787),
				_Utils_Tuple3(1.546, 0.598, -1.712),
				_Utils_Tuple3(1.894, 0.598, -1.7),
				_Utils_Tuple3(1.681, -0.363, -2.372),
				_Utils_Tuple3(1.886, -0.402, -1.746),
				_Utils_Tuple3(2.691, 0.598, -1.317),
				_Utils_Tuple3(1.645, -0.402, -1.683),
				_Utils_Tuple3(1.886, -0.402, -1.919),
				_Utils_Tuple3(1.635, -0.043, -2.453)
			]),
		aJ: _List_fromArray(
			[
				_Utils_Tuple3(0, 1, 2),
				_Utils_Tuple3(2, 3, 4),
				_Utils_Tuple3(5, 6, 7),
				_Utils_Tuple3(7, 8, 9),
				_Utils_Tuple3(9, 10, 11),
				_Utils_Tuple3(11, 12, 13),
				_Utils_Tuple3(13, 14, 15),
				_Utils_Tuple3(15, 16, 17),
				_Utils_Tuple3(17, 18, 19),
				_Utils_Tuple3(20, 21, 22),
				_Utils_Tuple3(22, 23, 24),
				_Utils_Tuple3(24, 25, 26),
				_Utils_Tuple3(27, 28, 29),
				_Utils_Tuple3(30, 31, 32),
				_Utils_Tuple3(33, 34, 35),
				_Utils_Tuple3(36, 37, 38),
				_Utils_Tuple3(38, 39, 40),
				_Utils_Tuple3(41, 42, 29),
				_Utils_Tuple3(43, 44, 45),
				_Utils_Tuple3(45, 46, 47),
				_Utils_Tuple3(47, 48, 49),
				_Utils_Tuple3(50, 51, 52),
				_Utils_Tuple3(53, 54, 55),
				_Utils_Tuple3(52, 56, 50),
				_Utils_Tuple3(57, 58, 59),
				_Utils_Tuple3(60, 61, 62),
				_Utils_Tuple3(63, 64, 65),
				_Utils_Tuple3(66, 67, 68),
				_Utils_Tuple3(69, 70, 67),
				_Utils_Tuple3(71, 72, 73),
				_Utils_Tuple3(74, 75, 76),
				_Utils_Tuple3(77, 74, 78),
				_Utils_Tuple3(79, 78, 80),
				_Utils_Tuple3(74, 81, 80),
				_Utils_Tuple3(79, 82, 83),
				_Utils_Tuple3(83, 84, 85),
				_Utils_Tuple3(85, 86, 87),
				_Utils_Tuple3(87, 88, 89),
				_Utils_Tuple3(90, 91, 92),
				_Utils_Tuple3(91, 90, 93),
				_Utils_Tuple3(94, 95, 96),
				_Utils_Tuple3(96, 97, 98),
				_Utils_Tuple3(98, 99, 100),
				_Utils_Tuple3(100, 101, 102),
				_Utils_Tuple3(102, 103, 78),
				_Utils_Tuple3(78, 104, 77),
				_Utils_Tuple3(75, 105, 106),
				_Utils_Tuple3(107, 108, 109),
				_Utils_Tuple3(110, 111, 112),
				_Utils_Tuple3(113, 114, 115),
				_Utils_Tuple3(116, 117, 118),
				_Utils_Tuple3(118, 119, 120),
				_Utils_Tuple3(121, 122, 123),
				_Utils_Tuple3(121, 124, 125),
				_Utils_Tuple3(126, 127, 128),
				_Utils_Tuple3(129, 130, 131),
				_Utils_Tuple3(132, 133, 134),
				_Utils_Tuple3(133, 135, 134),
				_Utils_Tuple3(132, 136, 137),
				_Utils_Tuple3(137, 138, 132),
				_Utils_Tuple3(139, 140, 141),
				_Utils_Tuple3(115, 142, 143),
				_Utils_Tuple3(144, 145, 146),
				_Utils_Tuple3(147, 148, 149),
				_Utils_Tuple3(150, 151, 68),
				_Utils_Tuple3(45, 152, 43),
				_Utils_Tuple3(153, 154, 155),
				_Utils_Tuple3(156, 157, 158),
				_Utils_Tuple3(159, 160, 161),
				_Utils_Tuple3(162, 163, 164),
				_Utils_Tuple3(152, 165, 166),
				_Utils_Tuple3(166, 167, 168),
				_Utils_Tuple3(169, 170, 28),
				_Utils_Tuple3(171, 172, 173),
				_Utils_Tuple3(174, 175, 176),
				_Utils_Tuple3(176, 177, 178),
				_Utils_Tuple3(178, 179, 180),
				_Utils_Tuple3(180, 181, 182),
				_Utils_Tuple3(182, 183, 184),
				_Utils_Tuple3(184, 185, 186),
				_Utils_Tuple3(186, 187, 188),
				_Utils_Tuple3(188, 189, 190),
				_Utils_Tuple3(190, 191, 192),
				_Utils_Tuple3(192, 193, 194),
				_Utils_Tuple3(194, 195, 196),
				_Utils_Tuple3(196, 197, 198),
				_Utils_Tuple3(198, 199, 200),
				_Utils_Tuple3(200, 201, 202),
				_Utils_Tuple3(202, 203, 204),
				_Utils_Tuple3(204, 205, 206),
				_Utils_Tuple3(206, 207, 208),
				_Utils_Tuple3(209, 210, 0),
				_Utils_Tuple3(211, 4, 5),
				_Utils_Tuple3(198, 9, 11),
				_Utils_Tuple3(194, 15, 192),
				_Utils_Tuple3(182, 20, 22),
				_Utils_Tuple3(40, 173, 38),
				_Utils_Tuple3(33, 35, 36),
				_Utils_Tuple3(212, 29, 28),
				_Utils_Tuple3(213, 49, 164),
				_Utils_Tuple3(161, 53, 159),
				_Utils_Tuple3(51, 50, 158),
				_Utils_Tuple3(59, 156, 57),
				_Utils_Tuple3(156, 59, 214),
				_Utils_Tuple3(153, 62, 63),
				_Utils_Tuple3(67, 66, 69),
				_Utils_Tuple3(215, 150, 216),
				_Utils_Tuple3(217, 218, 72),
				_Utils_Tuple3(83, 102, 79),
				_Utils_Tuple3(219, 85, 89),
				_Utils_Tuple3(85, 87, 89),
				_Utils_Tuple3(91, 93, 219),
				_Utils_Tuple3(219, 94, 96),
				_Utils_Tuple3(96, 98, 100),
				_Utils_Tuple3(72, 71, 220),
				_Utils_Tuple3(76, 220, 71),
				_Utils_Tuple3(73, 72, 218),
				_Utils_Tuple3(107, 109, 221),
				_Utils_Tuple3(110, 112, 222),
				_Utils_Tuple3(223, 118, 120),
				_Utils_Tuple3(122, 121, 224),
				_Utils_Tuple3(223, 120, 225),
				_Utils_Tuple3(127, 126, 226),
				_Utils_Tuple3(227, 228, 223),
				_Utils_Tuple3(133, 140, 229),
				_Utils_Tuple3(136, 132, 134),
				_Utils_Tuple3(115, 230, 142),
				_Utils_Tuple3(148, 147, 146),
				_Utils_Tuple3(216, 150, 68),
				_Utils_Tuple3(156, 214, 231),
				_Utils_Tuple3(159, 52, 51),
				_Utils_Tuple3(53, 161, 162),
				_Utils_Tuple3(47, 152, 45),
				_Utils_Tuple3(43, 166, 168),
				_Utils_Tuple3(171, 29, 212),
				_Utils_Tuple3(30, 232, 233),
				_Utils_Tuple3(26, 174, 176),
				_Utils_Tuple3(22, 180, 182),
				_Utils_Tuple3(184, 186, 188),
				_Utils_Tuple3(17, 190, 192),
				_Utils_Tuple3(11, 196, 198),
				_Utils_Tuple3(208, 204, 206),
				_Utils_Tuple3(202, 208, 211),
				_Utils_Tuple3(2, 209, 0),
				_Utils_Tuple3(4, 209, 2),
				_Utils_Tuple3(15, 194, 13),
				_Utils_Tuple3(29, 171, 41),
				_Utils_Tuple3(234, 38, 173),
				_Utils_Tuple3(52, 159, 55),
				_Utils_Tuple3(235, 236, 237),
				_Utils_Tuple3(69, 237, 236),
				_Utils_Tuple3(106, 76, 75),
				_Utils_Tuple3(85, 219, 83),
				_Utils_Tuple3(94, 219, 93),
				_Utils_Tuple3(219, 96, 100),
				_Utils_Tuple3(150, 215, 238),
				_Utils_Tuple3(239, 238, 215),
				_Utils_Tuple3(125, 224, 121),
				_Utils_Tuple3(226, 129, 227),
				_Utils_Tuple3(129, 226, 126),
				_Utils_Tuple3(116, 230, 115),
				_Utils_Tuple3(140, 139, 229),
				_Utils_Tuple3(133, 132, 140),
				_Utils_Tuple3(240, 146, 147),
				_Utils_Tuple3(236, 235, 65),
				_Utils_Tuple3(57, 158, 50),
				_Utils_Tuple3(152, 47, 213),
				_Utils_Tuple3(28, 241, 169),
				_Utils_Tuple3(241, 28, 27),
				_Utils_Tuple3(242, 233, 232),
				_Utils_Tuple3(26, 178, 24),
				_Utils_Tuple3(180, 24, 178),
				_Utils_Tuple3(19, 184, 188),
				_Utils_Tuple3(7, 198, 200),
				_Utils_Tuple3(208, 202, 204),
				_Utils_Tuple3(4, 211, 209),
				_Utils_Tuple3(200, 5, 7),
				_Utils_Tuple3(190, 17, 19),
				_Utils_Tuple3(169, 241, 168),
				_Utils_Tuple3(41, 171, 40),
				_Utils_Tuple3(216, 68, 67),
				_Utils_Tuple3(220, 76, 106),
				_Utils_Tuple3(100, 83, 219),
				_Utils_Tuple3(102, 83, 100),
				_Utils_Tuple3(238, 239, 217),
				_Utils_Tuple3(224, 125, 120),
				_Utils_Tuple3(131, 227, 129),
				_Utils_Tuple3(141, 243, 139),
				_Utils_Tuple3(116, 141, 230),
				_Utils_Tuple3(221, 240, 107),
				_Utils_Tuple3(36, 234, 33),
				_Utils_Tuple3(174, 244, 242),
				_Utils_Tuple3(244, 174, 26),
				_Utils_Tuple3(190, 19, 188),
				_Utils_Tuple3(9, 198, 7),
				_Utils_Tuple3(211, 200, 202),
				_Utils_Tuple3(43, 168, 241),
				_Utils_Tuple3(237, 69, 66),
				_Utils_Tuple3(75, 74, 77),
				_Utils_Tuple3(78, 79, 102),
				_Utils_Tuple3(225, 120, 125),
				_Utils_Tuple3(243, 118, 223),
				_Utils_Tuple3(118, 141, 116),
				_Utils_Tuple3(107, 217, 72),
				_Utils_Tuple3(245, 33, 234),
				_Utils_Tuple3(233, 242, 244),
				_Utils_Tuple3(13, 196, 11),
				_Utils_Tuple3(211, 5, 200),
				_Utils_Tuple3(166, 43, 152),
				_Utils_Tuple3(218, 217, 239),
				_Utils_Tuple3(80, 78, 74),
				_Utils_Tuple3(228, 227, 131),
				_Utils_Tuple3(243, 223, 228),
				_Utils_Tuple3(33, 245, 32),
				_Utils_Tuple3(38, 234, 36),
				_Utils_Tuple3(196, 13, 194),
				_Utils_Tuple3(65, 235, 63),
				_Utils_Tuple3(141, 118, 243),
				_Utils_Tuple3(113, 143, 144),
				_Utils_Tuple3(32, 245, 30),
				_Utils_Tuple3(17, 192, 15),
				_Utils_Tuple3(153, 63, 235),
				_Utils_Tuple3(143, 113, 115),
				_Utils_Tuple3(232, 30, 245),
				_Utils_Tuple3(20, 184, 19),
				_Utils_Tuple3(62, 153, 60),
				_Utils_Tuple3(222, 113, 144),
				_Utils_Tuple3(173, 40, 171),
				_Utils_Tuple3(184, 20, 182),
				_Utils_Tuple3(155, 60, 153),
				_Utils_Tuple3(110, 222, 144),
				_Utils_Tuple3(49, 213, 47),
				_Utils_Tuple3(180, 22, 24),
				_Utils_Tuple3(231, 60, 155),
				_Utils_Tuple3(146, 110, 144),
				_Utils_Tuple3(246, 164, 49),
				_Utils_Tuple3(178, 26, 176),
				_Utils_Tuple3(60, 231, 214),
				_Utils_Tuple3(240, 110, 146),
				_Utils_Tuple3(164, 246, 162),
				_Utils_Tuple3(110, 240, 221),
				_Utils_Tuple3(53, 162, 246),
				_Utils_Tuple3(217, 107, 240),
				_Utils_Tuple3(55, 159, 53),
				_Utils_Tuple3(158, 57, 156)
			])
	},
		{
		fn: _List_fromArray(
			[
				_Utils_Tuple3(0.576, -0.402, -0.743),
				_Utils_Tuple3(0.556, -0.402, -0.743),
				_Utils_Tuple3(0.551, -0.402, -0.763),
				_Utils_Tuple3(0.516, -0.402, -0.768),
				_Utils_Tuple3(0.511, -0.402, -0.788),
				_Utils_Tuple3(0.476, -0.402, -0.793),
				_Utils_Tuple3(0.476, -0.402, -0.808),
				_Utils_Tuple3(0.456, -0.402, -0.828),
				_Utils_Tuple3(0.436, -0.402, -0.828),
				_Utils_Tuple3(0.421, -0.402, -0.858),
				_Utils_Tuple3(0.386, -0.402, -0.868),
				_Utils_Tuple3(0.386, -0.402, -0.883),
				_Utils_Tuple3(0.371, -0.402, -0.888),
				_Utils_Tuple3(0.346, -0.402, -0.923),
				_Utils_Tuple3(0.311, -0.402, -0.933),
				_Utils_Tuple3(0.311, -0.402, -0.943),
				_Utils_Tuple3(0.276, -0.402, -1.053),
				_Utils_Tuple3(0.286, -0.402, -0.958),
				_Utils_Tuple3(0.256, -0.402, -0.998),
				_Utils_Tuple3(0.236, -0.402, -0.998),
				_Utils_Tuple3(0.226, -0.402, -1.018),
				_Utils_Tuple3(0.211, -0.402, -1.023),
				_Utils_Tuple3(0.186, -0.402, -1.053),
				_Utils_Tuple3(0.366, -0.402, -1.053),
				_Utils_Tuple3(0.371, -0.402, -1.068),
				_Utils_Tuple3(0.457, -0.402, -1.068),
				_Utils_Tuple3(0.886, -0.402, -1.068),
				_Utils_Tuple3(0.971, -0.402, -1.068),
				_Utils_Tuple3(0.971, -0.402, -1.048),
				_Utils_Tuple3(0.986, -0.402, -1.043),
				_Utils_Tuple3(0.981, -0.402, -1.003),
				_Utils_Tuple3(0.996, -0.402, -0.998),
				_Utils_Tuple3(1, -0.402, -0.97),
				_Utils_Tuple3(0.947, -0.402, -0.955),
				_Utils_Tuple3(0.893, -0.402, -0.94),
				_Utils_Tuple3(0.632, -0.402, -0.779),
				_Utils_Tuple3(0.584, -0.402, -0.735),
				_Utils_Tuple3(0.629, -0.402, -1.068),
				_Utils_Tuple3(0.68, -0.402, -0.823),
				_Utils_Tuple3(0.543, -0.402, -1.068),
				_Utils_Tuple3(0.734, -0.402, -0.858),
				_Utils_Tuple3(0.8, -0.402, -1.068),
				_Utils_Tuple3(0.789, -0.402, -0.893),
				_Utils_Tuple3(0.841, -0.402, -0.917),
				_Utils_Tuple3(0.714, -0.402, -1.068)
			]),
		aJ: _List_fromArray(
			[
				_Utils_Tuple3(0, 1, 2),
				_Utils_Tuple3(2, 3, 4),
				_Utils_Tuple3(4, 5, 6),
				_Utils_Tuple3(7, 8, 9),
				_Utils_Tuple3(9, 10, 11),
				_Utils_Tuple3(11, 12, 13),
				_Utils_Tuple3(13, 14, 15),
				_Utils_Tuple3(16, 17, 18),
				_Utils_Tuple3(18, 19, 20),
				_Utils_Tuple3(16, 21, 22),
				_Utils_Tuple3(23, 24, 25),
				_Utils_Tuple3(26, 27, 28),
				_Utils_Tuple3(28, 29, 30),
				_Utils_Tuple3(30, 31, 32),
				_Utils_Tuple3(26, 33, 34),
				_Utils_Tuple3(35, 36, 0),
				_Utils_Tuple3(4, 6, 7),
				_Utils_Tuple3(25, 13, 23),
				_Utils_Tuple3(23, 17, 16),
				_Utils_Tuple3(21, 16, 20),
				_Utils_Tuple3(37, 38, 39),
				_Utils_Tuple3(30, 26, 28),
				_Utils_Tuple3(33, 30, 32),
				_Utils_Tuple3(2, 35, 0),
				_Utils_Tuple3(39, 7, 9),
				_Utils_Tuple3(15, 23, 13),
				_Utils_Tuple3(20, 16, 18),
				_Utils_Tuple3(38, 37, 40),
				_Utils_Tuple3(26, 34, 41),
				_Utils_Tuple3(26, 30, 33),
				_Utils_Tuple3(4, 35, 2),
				_Utils_Tuple3(11, 25, 9),
				_Utils_Tuple3(17, 23, 15),
				_Utils_Tuple3(42, 41, 43),
				_Utils_Tuple3(43, 41, 34),
				_Utils_Tuple3(35, 4, 38),
				_Utils_Tuple3(13, 25, 11),
				_Utils_Tuple3(41, 42, 44),
				_Utils_Tuple3(39, 4, 7),
				_Utils_Tuple3(39, 9, 25),
				_Utils_Tuple3(40, 44, 42),
				_Utils_Tuple3(4, 39, 38),
				_Utils_Tuple3(44, 40, 37)
			])
	},
		{
		fn: _List_fromArray(
			[
				_Utils_Tuple3(0.254, -0.402, -0.163),
				_Utils_Tuple3(0.201, -0.402, -0.163),
				_Utils_Tuple3(0.201, -0.402, -0.258),
				_Utils_Tuple3(0.186, -0.402, -0.263),
				_Utils_Tuple3(0.186, -0.402, -0.356),
				_Utils_Tuple3(0.186, -0.402, -0.543),
				_Utils_Tuple3(0.176, -0.402, -0.548),
				_Utils_Tuple3(0.176, -0.402, -0.608),
				_Utils_Tuple3(0.176, -0.402, -0.668),
				_Utils_Tuple3(0.161, -0.402, -0.673),
				_Utils_Tuple3(0.161, -0.402, -0.759),
				_Utils_Tuple3(0.171, -0.402, -1.008),
				_Utils_Tuple3(0.161, -0.402, -1.018),
				_Utils_Tuple3(0.171, -0.402, -1.018),
				_Utils_Tuple3(0.161, -0.402, -0.932),
				_Utils_Tuple3(0.196, -0.402, -0.993),
				_Utils_Tuple3(0.211, -0.402, -0.968),
				_Utils_Tuple3(0.231, -0.402, -0.968),
				_Utils_Tuple3(0.231, -0.402, -0.958),
				_Utils_Tuple3(0.246, -0.402, -0.953),
				_Utils_Tuple3(0.286, -0.402, -0.903),
				_Utils_Tuple3(0.321, -0.402, -0.893),
				_Utils_Tuple3(0.336, -0.402, -0.868),
				_Utils_Tuple3(0.356, -0.402, -0.863),
				_Utils_Tuple3(0.376, -0.402, -0.838),
				_Utils_Tuple3(0.401, -0.402, -0.828),
				_Utils_Tuple3(0.421, -0.402, -0.793),
				_Utils_Tuple3(0.471, -0.402, -0.783),
				_Utils_Tuple3(0.471, -0.402, -0.763),
				_Utils_Tuple3(0.481, -0.402, -0.753),
				_Utils_Tuple3(0.541, -0.402, -0.728),
				_Utils_Tuple3(0.541, -0.402, -0.713),
				_Utils_Tuple3(0.558, -0.402, -0.706),
				_Utils_Tuple3(0.518, -0.402, -0.648),
				_Utils_Tuple3(0.381, -0.402, -0.249),
				_Utils_Tuple3(0.377, -0.402, -0.178),
				_Utils_Tuple3(0.336, -0.402, -0.178),
				_Utils_Tuple3(0.321, -0.402, -0.153),
				_Utils_Tuple3(0.306, -0.402, -0.163),
				_Utils_Tuple3(0.402, -0.402, -0.39),
				_Utils_Tuple3(0.186, -0.402, -0.45),
				_Utils_Tuple3(0.478, -0.402, -0.59),
				_Utils_Tuple3(0.161, -0.402, -0.846),
				_Utils_Tuple3(0.419, -0.402, -0.459),
				_Utils_Tuple3(0.385, -0.402, -0.32),
				_Utils_Tuple3(0.448, -0.402, -0.525)
			]),
		aJ: _List_fromArray(
			[
				_Utils_Tuple3(0, 1, 2),
				_Utils_Tuple3(2, 3, 4),
				_Utils_Tuple3(5, 6, 7),
				_Utils_Tuple3(8, 9, 10),
				_Utils_Tuple3(11, 12, 13),
				_Utils_Tuple3(14, 15, 16),
				_Utils_Tuple3(16, 17, 18),
				_Utils_Tuple3(14, 19, 20),
				_Utils_Tuple3(20, 21, 22),
				_Utils_Tuple3(22, 23, 24),
				_Utils_Tuple3(24, 25, 26),
				_Utils_Tuple3(26, 27, 28),
				_Utils_Tuple3(29, 30, 31),
				_Utils_Tuple3(31, 32, 33),
				_Utils_Tuple3(34, 35, 36),
				_Utils_Tuple3(36, 37, 38),
				_Utils_Tuple3(38, 0, 2),
				_Utils_Tuple3(39, 4, 40),
				_Utils_Tuple3(41, 7, 8),
				_Utils_Tuple3(22, 10, 42),
				_Utils_Tuple3(12, 11, 14),
				_Utils_Tuple3(14, 20, 42),
				_Utils_Tuple3(8, 24, 26),
				_Utils_Tuple3(41, 29, 33),
				_Utils_Tuple3(29, 31, 33),
				_Utils_Tuple3(2, 34, 36),
				_Utils_Tuple3(36, 38, 2),
				_Utils_Tuple3(43, 40, 5),
				_Utils_Tuple3(15, 14, 11),
				_Utils_Tuple3(28, 41, 26),
				_Utils_Tuple3(29, 41, 28),
				_Utils_Tuple3(2, 44, 34),
				_Utils_Tuple3(44, 2, 4),
				_Utils_Tuple3(18, 14, 16),
				_Utils_Tuple3(8, 26, 41),
				_Utils_Tuple3(4, 39, 44),
				_Utils_Tuple3(7, 45, 5),
				_Utils_Tuple3(19, 14, 18),
				_Utils_Tuple3(22, 42, 20),
				_Utils_Tuple3(40, 43, 39),
				_Utils_Tuple3(24, 10, 22),
				_Utils_Tuple3(5, 45, 43),
				_Utils_Tuple3(24, 8, 10),
				_Utils_Tuple3(7, 41, 45)
			])
	},
		{
		fn: _List_fromArray(
			[
				_Utils_Tuple3(0.559, 0.539, -0.243),
				_Utils_Tuple3(0.563, 0.535, -0.231),
				_Utils_Tuple3(0.621, 0.476, -0.223),
				_Utils_Tuple3(0.652, 0.425, -0.232),
				_Utils_Tuple3(0.654, 0.42, -0.222),
				_Utils_Tuple3(0.677, 0.341, -0.221),
				_Utils_Tuple3(0.678, 0.336, -0.206),
				_Utils_Tuple3(0.681, 0.268, -0.206),
				_Utils_Tuple3(0.681, 0.131, -0.206),
				_Utils_Tuple3(0.681, 0.126, -0.196),
				_Utils_Tuple3(0.681, 0.116, -0.206),
				_Utils_Tuple3(0.681, 0.081, -0.206),
				_Utils_Tuple3(0.681, 0.076, -0.196),
				_Utils_Tuple3(0.681, 0.016, -0.196),
				_Utils_Tuple3(0.688, 0.016, -0.29),
				_Utils_Tuple3(0.689, 0.031, -0.295),
				_Utils_Tuple3(0.7, 0.031, -0.339),
				_Utils_Tuple3(0.701, 0.041, -0.344),
				_Utils_Tuple3(0.726, 0.071, -0.409),
				_Utils_Tuple3(0.733, 0.041, -0.422),
				_Utils_Tuple3(0.733, 0.066, -0.422),
				_Utils_Tuple3(0.726, 0.091, -0.409),
				_Utils_Tuple3(0.733, 0.096, -0.422),
				_Utils_Tuple3(0.733, 0.176, -0.422),
				_Utils_Tuple3(0.73, 0.336, -0.424),
				_Utils_Tuple3(0.734, 0.341, -0.433),
				_Utils_Tuple3(0.717, 0.41, -0.442),
				_Utils_Tuple3(0.801, 0.031, -0.521),
				_Utils_Tuple3(0.942, 0.026, -0.63),
				_Utils_Tuple3(0.752, 0.184, -0.456),
				_Utils_Tuple3(0.753, 0.106, -0.457),
				_Utils_Tuple3(0.748, 0.101, -0.449),
				_Utils_Tuple3(0.748, 0.056, -0.449),
				_Utils_Tuple3(0.753, 0.041, -0.457),
				_Utils_Tuple3(0.775, -0.014, -0.49),
				_Utils_Tuple3(0.772, 0.001, -0.486),
				_Utils_Tuple3(0.731, 0.001, -0.418),
				_Utils_Tuple3(0.701, 0.001, -0.344),
				_Utils_Tuple3(0.7, -0.014, -0.339),
				_Utils_Tuple3(0.689, -0.014, -0.295),
				_Utils_Tuple3(0.688, -0.024, -0.29),
				_Utils_Tuple3(0.681, -0.024, -0.206),
				_Utils_Tuple3(0.681, -0.059, -0.206),
				_Utils_Tuple3(0.681, -0.064, -0.196),
				_Utils_Tuple3(0.681, -0.099, -0.196),
				_Utils_Tuple3(0.612, -0.29, -0.2),
				_Utils_Tuple3(0.439, -0.402, -0.512),
				_Utils_Tuple3(0.543, -0.352, -0.206),
				_Utils_Tuple3(0.52, -0.366, -0.192),
				_Utils_Tuple3(0.454, -0.392, -0.195),
				_Utils_Tuple3(0.376, -0.402, -0.197),
				_Utils_Tuple3(0.391, -0.402, -0.358),
				_Utils_Tuple3(1.023, -0.341, -0.788),
				_Utils_Tuple3(0.899, -0.402, -0.942),
				_Utils_Tuple3(0.982, -0.398, -0.92),
				_Utils_Tuple3(1.059, -0.389, -0.893),
				_Utils_Tuple3(1.028, -0.38, -0.86),
				_Utils_Tuple3(1.044, -0.356, -0.814),
				_Utils_Tuple3(1.037, -0.309, -0.754),
				_Utils_Tuple3(1.049, -0.305, -0.753),
				_Utils_Tuple3(1.057, -0.255, -0.716),
				_Utils_Tuple3(1.068, -0.251, -0.715),
				_Utils_Tuple3(1.061, -0.212, -0.694),
				_Utils_Tuple3(1.031, -0.014, -0.664),
				_Utils_Tuple3(1.065, 0.001, -0.672),
				_Utils_Tuple3(1.036, 0.001, -0.666),
				_Utils_Tuple3(1.021, 0.026, -0.662),
				_Utils_Tuple3(1.026, 0.041, -0.663),
				_Utils_Tuple3(1.065, 0.041, -0.672),
				_Utils_Tuple3(1.065, 0.131, -0.672),
				_Utils_Tuple3(1.08, 0.136, -0.675),
				_Utils_Tuple3(1.085, 0.151, -0.676),
				_Utils_Tuple3(1.219, -0.042, -0.677),
				_Utils_Tuple3(1.22, -0.139, -0.68),
				_Utils_Tuple3(1.23, -0.144, -0.679),
				_Utils_Tuple3(1.229, -0.198, -0.693),
				_Utils_Tuple3(1.23, -0.251, -0.717),
				_Utils_Tuple3(1.241, -0.251, -0.716),
				_Utils_Tuple3(1.259, -0.269, -0.724),
				_Utils_Tuple3(1.271, -0.305, -0.751),
				_Utils_Tuple3(1.283, -0.309, -0.752),
				_Utils_Tuple3(1.304, -0.359, -0.812),
				_Utils_Tuple3(1.321, -0.369, -0.826),
				_Utils_Tuple3(1.329, -0.383, -0.857),
				_Utils_Tuple3(1.305, -0.396, -0.913),
				_Utils_Tuple3(1.411, -0.402, -0.942),
				_Utils_Tuple3(1.488, -0.402, -0.911),
				_Utils_Tuple3(1.561, -0.402, -0.872),
				_Utils_Tuple3(1.571, -0.399, -0.816),
				_Utils_Tuple3(1.555, -0.377, -0.732),
				_Utils_Tuple3(1.54, -0.375, -0.735),
				_Utils_Tuple3(1.511, -0.334, -0.674),
				_Utils_Tuple3(1.477, -0.283, -0.638),
				_Utils_Tuple3(1.448, -0.241, -0.626),
				_Utils_Tuple3(1.433, -0.237, -0.633),
				_Utils_Tuple3(1.422, -0.153, -0.606),
				_Utils_Tuple3(1.413, -0.149, -0.611),
				_Utils_Tuple3(1.41, 0.201, -0.607),
				_Utils_Tuple3(1.423, 0.206, -0.599),
				_Utils_Tuple3(1.423, 0.281, -0.599),
				_Utils_Tuple3(1.423, 0.361, -0.608),
				_Utils_Tuple3(1.431, 0.286, -0.593),
				_Utils_Tuple3(1.435, 0.356, -0.599),
				_Utils_Tuple3(1.43, 0.405, -0.619),
				_Utils_Tuple3(1.44, 0.41, -0.615),
				_Utils_Tuple3(1.456, 0.462, -0.638),
				_Utils_Tuple3(1.486, 0.489, -0.641),
				_Utils_Tuple3(1.501, 0.523, -0.671),
				_Utils_Tuple3(1.366, 0.575, -0.833),
				_Utils_Tuple3(1.565, 0.577, -0.734),
				_Utils_Tuple3(1.513, 0.598, -0.899),
				_Utils_Tuple3(1.614, 0.597, -0.797),
				_Utils_Tuple3(1.605, 0.598, -0.843),
				_Utils_Tuple3(1.414, 0.598, -0.941),
				_Utils_Tuple3(1.338, 0.596, -0.923),
				_Utils_Tuple3(1.257, 0.391, -0.686),
				_Utils_Tuple3(1.269, 0.439, -0.705),
				_Utils_Tuple3(1.247, 0.386, -0.687),
				_Utils_Tuple3(1.239, 0.316, -0.675),
				_Utils_Tuple3(1.219, 0.311, -0.677),
				_Utils_Tuple3(1.214, 0.296, -0.677),
				_Utils_Tuple3(1.078, 0.371, -0.685),
				_Utils_Tuple3(1.075, 0.425, -0.704),
				_Utils_Tuple3(1.023, 0.427, -0.694),
				_Utils_Tuple3(1.018, 0.458, -0.71),
				_Utils_Tuple3(1.078, 0.458, -0.723),
				_Utils_Tuple3(1.078, 0.507, -0.762),
				_Utils_Tuple3(0.998, 0.593, -0.913),
				_Utils_Tuple3(1.077, 0.55, -0.815),
				_Utils_Tuple3(1.065, 0.572, -0.855),
				_Utils_Tuple3(1.09, 0.58, -0.877),
				_Utils_Tuple3(0.961, 0.458, -0.691),
				_Utils_Tuple3(0.896, 0.598, -0.941),
				_Utils_Tuple3(0.755, 0.598, -0.874),
				_Utils_Tuple3(0.729, 0.415, -0.466),
				_Utils_Tuple3(0.63, 0.598, -0.781),
				_Utils_Tuple3(0.526, 0.598, -0.666),
				_Utils_Tuple3(0.397, 0.598, -0.384),
				_Utils_Tuple3(0.377, 0.598, -0.23),
				_Utils_Tuple3(0.476, 0.582, -0.249),
				_Utils_Tuple3(0.631, 0.462, -0.233),
				_Utils_Tuple3(0.733, 0.256, -0.422),
				_Utils_Tuple3(0.681, 0.2, -0.206),
				_Utils_Tuple3(0.656, -0.217, -0.195),
				_Utils_Tuple3(0.681, -0.104, -0.206),
				_Utils_Tuple3(0.752, -0.402, -0.873),
				_Utils_Tuple3(0.804, -0.009, -0.525),
				_Utils_Tuple3(1.065, -0.07, -0.672),
				_Utils_Tuple3(1.41, -0.061, -0.607),
				_Utils_Tuple3(1.353, 0.553, -0.794),
				_Utils_Tuple3(0.972, 0.43, -0.678),
				_Utils_Tuple3(0.674, -0.161, -0.201),
				_Utils_Tuple3(0.979, -0.011, -0.647),
				_Utils_Tuple3(1.064, -0.142, -0.675),
				_Utils_Tuple3(1.152, 0.151, -0.681),
				_Utils_Tuple3(1.095, 0.296, -0.677),
				_Utils_Tuple3(1.526, 0.542, -0.683),
				_Utils_Tuple3(1.219, 0.151, -0.677),
				_Utils_Tuple3(1.41, 0.114, -0.607),
				_Utils_Tuple3(1.08, 0.316, -0.676),
				_Utils_Tuple3(0.448, 0.598, -0.532),
				_Utils_Tuple3(0.929, 0.011, -0.623),
				_Utils_Tuple3(0.624, -0.402, -0.775),
				_Utils_Tuple3(0.929, -0.009, -0.623),
				_Utils_Tuple3(1.328, 0.523, -0.759),
				_Utils_Tuple3(1.284, 0.485, -0.733),
				_Utils_Tuple3(0.751, 0.261, -0.455),
				_Utils_Tuple3(0.748, 0.339, -0.456),
				_Utils_Tuple3(0.518, -0.402, -0.653),
				_Utils_Tuple3(1.41, 0.026, -0.607),
				_Utils_Tuple3(1.219, 0.055, -0.677),
				_Utils_Tuple3(1.154, 0.296, -0.681)
			]),
		aJ: _List_fromArray(
			[
				_Utils_Tuple3(0, 1, 2),
				_Utils_Tuple3(3, 4, 5),
				_Utils_Tuple3(5, 6, 7),
				_Utils_Tuple3(8, 9, 10),
				_Utils_Tuple3(11, 12, 13),
				_Utils_Tuple3(13, 14, 15),
				_Utils_Tuple3(15, 16, 17),
				_Utils_Tuple3(18, 19, 20),
				_Utils_Tuple3(21, 22, 23),
				_Utils_Tuple3(24, 25, 26),
				_Utils_Tuple3(27, 28, 29),
				_Utils_Tuple3(30, 31, 32),
				_Utils_Tuple3(30, 33, 27),
				_Utils_Tuple3(34, 35, 36),
				_Utils_Tuple3(36, 37, 38),
				_Utils_Tuple3(38, 39, 40),
				_Utils_Tuple3(40, 41, 42),
				_Utils_Tuple3(42, 43, 44),
				_Utils_Tuple3(34, 45, 46),
				_Utils_Tuple3(47, 48, 49),
				_Utils_Tuple3(49, 50, 51),
				_Utils_Tuple3(52, 53, 54),
				_Utils_Tuple3(54, 55, 56),
				_Utils_Tuple3(56, 57, 52),
				_Utils_Tuple3(58, 59, 60),
				_Utils_Tuple3(60, 61, 62),
				_Utils_Tuple3(63, 64, 65),
				_Utils_Tuple3(28, 66, 67),
				_Utils_Tuple3(67, 68, 69),
				_Utils_Tuple3(69, 70, 71),
				_Utils_Tuple3(72, 73, 74),
				_Utils_Tuple3(75, 76, 77),
				_Utils_Tuple3(78, 79, 80),
				_Utils_Tuple3(80, 81, 82),
				_Utils_Tuple3(83, 84, 85),
				_Utils_Tuple3(86, 87, 88),
				_Utils_Tuple3(88, 89, 90),
				_Utils_Tuple3(80, 91, 92),
				_Utils_Tuple3(92, 93, 94),
				_Utils_Tuple3(94, 95, 96),
				_Utils_Tuple3(97, 98, 99),
				_Utils_Tuple3(100, 101, 102),
				_Utils_Tuple3(103, 104, 105),
				_Utils_Tuple3(105, 106, 107),
				_Utils_Tuple3(108, 109, 110),
				_Utils_Tuple3(109, 111, 112),
				_Utils_Tuple3(108, 113, 114),
				_Utils_Tuple3(115, 103, 116),
				_Utils_Tuple3(115, 117, 118),
				_Utils_Tuple3(118, 119, 120),
				_Utils_Tuple3(121, 122, 123),
				_Utils_Tuple3(124, 125, 126),
				_Utils_Tuple3(127, 128, 129),
				_Utils_Tuple3(129, 130, 127),
				_Utils_Tuple3(131, 132, 133),
				_Utils_Tuple3(134, 135, 136),
				_Utils_Tuple3(137, 138, 139),
				_Utils_Tuple3(0, 2, 140),
				_Utils_Tuple3(141, 7, 142),
				_Utils_Tuple3(11, 13, 15),
				_Utils_Tuple3(19, 18, 17),
				_Utils_Tuple3(142, 23, 141),
				_Utils_Tuple3(33, 30, 32),
				_Utils_Tuple3(143, 36, 38),
				_Utils_Tuple3(144, 40, 42),
				_Utils_Tuple3(42, 44, 144),
				_Utils_Tuple3(45, 34, 143),
				_Utils_Tuple3(47, 49, 51),
				_Utils_Tuple3(53, 52, 145),
				_Utils_Tuple3(54, 56, 52),
				_Utils_Tuple3(146, 60, 62),
				_Utils_Tuple3(64, 63, 147),
				_Utils_Tuple3(28, 67, 69),
				_Utils_Tuple3(148, 72, 74),
				_Utils_Tuple3(78, 75, 77),
				_Utils_Tuple3(86, 83, 85),
				_Utils_Tuple3(90, 86, 88),
				_Utils_Tuple3(82, 90, 91),
				_Utils_Tuple3(101, 100, 99),
				_Utils_Tuple3(149, 109, 108),
				_Utils_Tuple3(109, 112, 110),
				_Utils_Tuple3(113, 108, 110),
				_Utils_Tuple3(99, 118, 97),
				_Utils_Tuple3(150, 121, 123),
				_Utils_Tuple3(131, 124, 126),
				_Utils_Tuple3(131, 128, 127),
				_Utils_Tuple3(131, 133, 135),
				_Utils_Tuple3(0, 137, 139),
				_Utils_Tuple3(26, 140, 3),
				_Utils_Tuple3(17, 8, 15),
				_Utils_Tuple3(10, 11, 15),
				_Utils_Tuple3(21, 17, 18),
				_Utils_Tuple3(5, 141, 24),
				_Utils_Tuple3(29, 30, 27),
				_Utils_Tuple3(151, 40, 144),
				_Utils_Tuple3(46, 45, 47),
				_Utils_Tuple3(47, 51, 46),
				_Utils_Tuple3(58, 145, 52),
				_Utils_Tuple3(147, 152, 153),
				_Utils_Tuple3(152, 147, 63),
				_Utils_Tuple3(154, 155, 71),
				_Utils_Tuple3(94, 78, 80),
				_Utils_Tuple3(94, 75, 78),
				_Utils_Tuple3(86, 82, 83),
				_Utils_Tuple3(82, 86, 90),
				_Utils_Tuple3(118, 99, 100),
				_Utils_Tuple3(156, 149, 107),
				_Utils_Tuple3(109, 149, 156),
				_Utils_Tuple3(97, 157, 158),
				_Utils_Tuple3(121, 150, 159),
				_Utils_Tuple3(128, 131, 126),
				_Utils_Tuple3(134, 136, 160),
				_Utils_Tuple3(137, 0, 160),
				_Utils_Tuple3(23, 8, 17),
				_Utils_Tuple3(8, 10, 15),
				_Utils_Tuple3(23, 17, 21),
				_Utils_Tuple3(28, 27, 161),
				_Utils_Tuple3(40, 151, 38),
				_Utils_Tuple3(143, 38, 151),
				_Utils_Tuple3(34, 162, 146),
				_Utils_Tuple3(163, 153, 152),
				_Utils_Tuple3(96, 75, 94),
				_Utils_Tuple3(91, 80, 82),
				_Utils_Tuple3(107, 164, 105),
				_Utils_Tuple3(164, 107, 149),
				_Utils_Tuple3(116, 105, 165),
				_Utils_Tuple3(166, 150, 167),
				_Utils_Tuple3(132, 131, 127),
				_Utils_Tuple3(26, 0, 140),
				_Utils_Tuple3(7, 141, 5),
				_Utils_Tuple3(8, 23, 142),
				_Utils_Tuple3(29, 28, 166),
				_Utils_Tuple3(36, 143, 34),
				_Utils_Tuple3(34, 46, 168),
				_Utils_Tuple3(153, 163, 62),
				_Utils_Tuple3(75, 96, 74),
				_Utils_Tuple3(80, 92, 94),
				_Utils_Tuple3(165, 105, 164),
				_Utils_Tuple3(157, 97, 118),
				_Utils_Tuple3(135, 134, 131),
				_Utils_Tuple3(24, 3, 5),
				_Utils_Tuple3(3, 24, 26),
				_Utils_Tuple3(162, 34, 168),
				_Utils_Tuple3(146, 62, 163),
				_Utils_Tuple3(148, 74, 96),
				_Utils_Tuple3(105, 116, 103),
				_Utils_Tuple3(131, 134, 150),
				_Utils_Tuple3(0, 26, 160),
				_Utils_Tuple3(145, 58, 162),
				_Utils_Tuple3(161, 146, 163),
				_Utils_Tuple3(169, 72, 148),
				_Utils_Tuple3(103, 115, 100),
				_Utils_Tuple3(160, 26, 134),
				_Utils_Tuple3(162, 58, 146),
				_Utils_Tuple3(60, 146, 58),
				_Utils_Tuple3(72, 169, 170),
				_Utils_Tuple3(118, 100, 115),
				_Utils_Tuple3(167, 150, 134),
				_Utils_Tuple3(146, 161, 27),
				_Utils_Tuple3(158, 170, 169),
				_Utils_Tuple3(150, 166, 159),
				_Utils_Tuple3(170, 158, 157),
				_Utils_Tuple3(69, 166, 28),
				_Utils_Tuple3(120, 157, 118),
				_Utils_Tuple3(166, 69, 159),
				_Utils_Tuple3(157, 120, 154),
				_Utils_Tuple3(71, 159, 69),
				_Utils_Tuple3(171, 154, 120),
				_Utils_Tuple3(159, 71, 155),
				_Utils_Tuple3(155, 154, 171)
			])
	}
	]);
var $elm$core$Basics$pow = _Basics_pow;
var $elm$core$Basics$sqrt = _Basics_sqrt;
var $author$project$Shapes$distance$ = function (a, b) {
	return $elm$core$Basics$sqrt(
		(A2($elm$core$Basics$pow, a.m - b.m, 2) + A2($elm$core$Basics$pow, a.n - b.n, 2)) + A2($elm$core$Basics$pow, a.o - b.o, 2));
};
var $author$project$Shapes$distance = F2($author$project$Shapes$distance$);
var $author$project$Shapes$lerp$ = function (t, a, b) {
	return {m: a.m + (t * (b.m - a.m)), n: a.n + (t * (b.n - a.n)), o: a.o + (t * (b.o - a.o))};
};
var $author$project$Shapes$lerp = F3($author$project$Shapes$lerp$);
var $elm$core$List$foldrHelper$ = function (fn, acc, ctr, ls) {
	if (!ls.b) {
		return acc;
	} else {
		var a = ls.a;
		var r1 = ls.b;
		if (!r1.b) {
			return A2(fn, a, acc);
		} else {
			var b = r1.a;
			var r2 = r1.b;
			if (!r2.b) {
				return A2(
					fn,
					a,
					A2(fn, b, acc));
			} else {
				var c = r2.a;
				var r3 = r2.b;
				if (!r3.b) {
					return A2(
						fn,
						a,
						A2(
							fn,
							b,
							A2(fn, c, acc)));
				} else {
					var d = r3.a;
					var r4 = r3.b;
					var res = (ctr > 500) ? $elm$core$List$foldl$(
						fn,
						acc,
						$elm$core$List$reverse(r4)) : $elm$core$List$foldrHelper$(fn, acc, ctr + 1, r4);
					return A2(
						fn,
						a,
						A2(
							fn,
							b,
							A2(
								fn,
								c,
								A2(fn, d, res))));
				}
			}
		}
	}
};
var $elm$core$List$foldrHelper = F4($elm$core$List$foldrHelper$);
var $elm$core$List$foldr$ = function (fn, acc, ls) {
	return $elm$core$List$foldrHelper$(fn, acc, 0, ls);
};
var $elm$core$List$foldr = F3($elm$core$List$foldr$);
var $elm$core$List$map$ = function (f, xs) {
	return $elm$core$List$foldr$(
		F2(
			function (x, acc) {
				return A2(
					$elm$core$List$cons,
					f(x),
					acc);
			}),
		_List_Nil,
		xs);
};
var $elm$core$List$map = F2($elm$core$List$map$);
var $author$project$Shapes$alongWall$ = function (step, points) {
	if (points.b && points.b.b) {
		var first = points.a;
		var _v1 = points.b;
		var second = _v1.a;
		var rest = _v1.b;
		var steps = $elm$core$Basics$max$(
			1,
			$elm$core$Basics$ceiling(
				$author$project$Shapes$distance$(first, second) / step));
		return _Utils_ap(
			$elm$core$List$map$(
				function (i) {
					return $author$project$Shapes$lerp$(i / steps, first, second);
				},
				$elm$core$List$range$(0, steps - 1)),
			$author$project$Shapes$alongWall$(
				step,
				A2($elm$core$List$cons, second, rest)));
	} else {
		return points;
	}
};
var $author$project$Shapes$alongWall = F2($author$project$Shapes$alongWall$);
var $elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var $elm$core$Elm$JsArray$slice = _JsArray_slice;
var $elm$core$Array$appendHelpBuilder$ = function (tail, builder) {
	var tailLen = $elm$core$Elm$JsArray$length(tail);
	var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(builder.M)) - tailLen;
	var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, builder.M, tail);
	return (notAppended < 0) ? {
		Q: A2(
			$elm$core$List$cons,
			$elm$core$Array$Leaf(appended),
			builder.Q),
		G: builder.G + 1,
		M: A3($elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
	} : ((!notAppended) ? {
		Q: A2(
			$elm$core$List$cons,
			$elm$core$Array$Leaf(appended),
			builder.Q),
		G: builder.G + 1,
		M: $elm$core$Elm$JsArray$empty
	} : {Q: builder.Q, G: builder.G, M: appended});
};
var $elm$core$Array$appendHelpBuilder = F2($elm$core$Array$appendHelpBuilder$);
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$insertTailInTree$ = function (shift, index, tail, tree) {
	var pos = $elm$core$Array$bitMask & (index >>> shift);
	if (_Utils_cmp(
		pos,
		$elm$core$Elm$JsArray$length(tree)) > -1) {
		if (shift === 5) {
			return A2(
				$elm$core$Elm$JsArray$push,
				$elm$core$Array$Leaf(tail),
				tree);
		} else {
			var newSub = $elm$core$Array$SubTree(
				$elm$core$Array$insertTailInTree$(shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
			return A2($elm$core$Elm$JsArray$push, newSub, tree);
		}
	} else {
		var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!value.$) {
			var subTree = value.a;
			var newSub = $elm$core$Array$SubTree(
				$elm$core$Array$insertTailInTree$(shift - $elm$core$Array$shiftStep, index, tail, subTree));
			return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
		} else {
			var newSub = $elm$core$Array$SubTree(
				$elm$core$Array$insertTailInTree$(
					shift - $elm$core$Array$shiftStep,
					index,
					tail,
					$elm$core$Elm$JsArray$singleton(value)));
			return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
		}
	}
};
var $elm$core$Array$insertTailInTree = F4($elm$core$Array$insertTailInTree$);
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$unsafeReplaceTail$ = function (newTail, _v0) {
	var len = _v0.a;
	var startShift = _v0.b;
	var tree = _v0.c;
	var tail = _v0.d;
	var originalTailLen = $elm$core$Elm$JsArray$length(tail);
	var newTailLen = $elm$core$Elm$JsArray$length(newTail);
	var newArrayLen = len + (newTailLen - originalTailLen);
	if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
		var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
		if (overflow) {
			var newShift = startShift + $elm$core$Array$shiftStep;
			var newTree = $elm$core$Array$insertTailInTree$(
				newShift,
				len,
				newTail,
				$elm$core$Elm$JsArray$singleton(
					$elm$core$Array$SubTree(tree)));
			return $elm$core$Array$Array_elm_builtin$(newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
		} else {
			return $elm$core$Array$Array_elm_builtin$(
				newArrayLen,
				startShift,
				$elm$core$Array$insertTailInTree$(startShift, len, newTail, tree),
				$elm$core$Elm$JsArray$empty);
		}
	} else {
		return $elm$core$Array$Array_elm_builtin$(newArrayLen, startShift, tree, newTail);
	}
};
var $elm$core$Array$unsafeReplaceTail = F2($elm$core$Array$unsafeReplaceTail$);
var $elm$core$Array$appendHelpTree$ = function (toAppend, array) {
	var len = array.a;
	var tree = array.c;
	var tail = array.d;
	var itemsToAppend = $elm$core$Elm$JsArray$length(toAppend);
	var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(tail)) - itemsToAppend;
	var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, tail, toAppend);
	var newArray = $elm$core$Array$unsafeReplaceTail$(appended, array);
	if (notAppended < 0) {
		var nextTail = A3($elm$core$Elm$JsArray$slice, notAppended, itemsToAppend, toAppend);
		return $elm$core$Array$unsafeReplaceTail$(nextTail, newArray);
	} else {
		return newArray;
	}
};
var $elm$core$Array$appendHelpTree = F2($elm$core$Array$appendHelpTree$);
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var $elm$core$Array$builderFromArray = function (_v0) {
	var len = _v0.a;
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (!node.$) {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				return A2($elm$core$List$cons, node, acc);
			}
		});
	return {
		Q: A3($elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		G: (len / $elm$core$Array$branchFactor) | 0,
		M: tail
	};
};
var $elm$core$Array$append$ = function (a, _v0) {
	var aTail = a.d;
	var bLen = _v0.a;
	var bTree = _v0.c;
	var bTail = _v0.d;
	if (_Utils_cmp(bLen, $elm$core$Array$branchFactor * 4) < 1) {
		var foldHelper = F2(
			function (node, array) {
				if (!node.$) {
					var tree = node.a;
					return A3($elm$core$Elm$JsArray$foldl, foldHelper, array, tree);
				} else {
					var leaf = node.a;
					return $elm$core$Array$appendHelpTree$(leaf, array);
				}
			});
		return $elm$core$Array$appendHelpTree$(
			bTail,
			A3($elm$core$Elm$JsArray$foldl, foldHelper, a, bTree));
	} else {
		var foldHelper = F2(
			function (node, builder) {
				if (!node.$) {
					var tree = node.a;
					return A3($elm$core$Elm$JsArray$foldl, foldHelper, builder, tree);
				} else {
					var leaf = node.a;
					return $elm$core$Array$appendHelpBuilder$(leaf, builder);
				}
			});
		return $elm$core$Array$builderToArray$(
			true,
			$elm$core$Array$appendHelpBuilder$(
				bTail,
				A3(
					$elm$core$Elm$JsArray$foldl,
					foldHelper,
					$elm$core$Array$builderFromArray(a),
					bTree)));
	}
};
var $elm$core$Array$append = F2($elm$core$Array$append$);
var $elm$core$Basics$composeR$ = function (f, g, x) {
	return g(
		f(x));
};
var $elm$core$Basics$composeR = F3($elm$core$Basics$composeR$);
var $elm$core$Array$fromListHelp$ = function (list, nodeList, nodeListSize) {
	fromListHelp:
	while (true) {
		var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
		var jsArray = _v0.a;
		var remainingItems = _v0.b;
		if (_Utils_cmp(
			$elm$core$Elm$JsArray$length(jsArray),
			$elm$core$Array$branchFactor) < 0) {
			return $elm$core$Array$builderToArray$(
				true,
				{Q: nodeList, G: nodeListSize, M: jsArray});
		} else {
			var $temp$list = remainingItems,
				$temp$nodeList = A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(jsArray),
				nodeList),
				$temp$nodeListSize = nodeListSize + 1;
			list = $temp$list;
			nodeList = $temp$nodeList;
			nodeListSize = $temp$nodeListSize;
			continue fromListHelp;
		}
	}
};
var $elm$core$Array$fromListHelp = F3($elm$core$Array$fromListHelp$);
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return $elm$core$Array$fromListHelp$(list, _List_Nil, 0);
	}
};
var $author$project$Shapes$fromTuple = function (_v0) {
	var x = _v0.a;
	var y = _v0.b;
	var z = _v0.c;
	return {m: x, n: y, o: z};
};
var $author$project$Shapes$cellSize = 0.2;
var $author$project$Shapes$cellOf = function (coordinate) {
	return $elm$core$Basics$floor(coordinate / $author$project$Shapes$cellSize);
};
var $elm$core$Array$getHelp$ = function (shift, index, tree) {
	getHelp:
	while (true) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!_v0.$) {
			var subTree = _v0.a;
			var $temp$shift = shift - $elm$core$Array$shiftStep,
				$temp$tree = subTree;
			shift = $temp$shift;
			tree = $temp$tree;
			continue getHelp;
		} else {
			var values = _v0.a;
			return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
		}
	}
};
var $elm$core$Array$getHelp = F3($elm$core$Array$getHelp$);
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$get$ = function (index, _v0) {
	var len = _v0.a;
	var startShift = _v0.b;
	var tree = _v0.c;
	var tail = _v0.d;
	return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
		index,
		$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
		A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
		$elm$core$Array$getHelp$(startShift, index, tree)));
};
var $elm$core$Array$get = F2($elm$core$Array$get$);
var $elm$core$List$maximum = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(
			$elm$core$List$foldl$($elm$core$Basics$max, x, xs));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$Basics$min$ = function (x, y) {
	return (_Utils_cmp(x, y) < 0) ? x : y;
};
var $elm$core$Basics$min = F2($elm$core$Basics$min$);
var $elm$core$List$minimum = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(
			$elm$core$List$foldl$($elm$core$Basics$min, x, xs));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$Array$repeat$ = function (n, e) {
	return $elm$core$Array$initialize$(
		n,
		function (_v0) {
			return e;
		});
};
var $elm$core$Array$repeat = F2($elm$core$Array$repeat$);
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$core$Array$setHelp$ = function (shift, index, value, tree) {
	var pos = $elm$core$Array$bitMask & (index >>> shift);
	var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
	if (!_v0.$) {
		var subTree = _v0.a;
		var newSub = $elm$core$Array$setHelp$(shift - $elm$core$Array$shiftStep, index, value, subTree);
		return A3(
			$elm$core$Elm$JsArray$unsafeSet,
			pos,
			$elm$core$Array$SubTree(newSub),
			tree);
	} else {
		var values = _v0.a;
		var newLeaf = A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, values);
		return A3(
			$elm$core$Elm$JsArray$unsafeSet,
			pos,
			$elm$core$Array$Leaf(newLeaf),
			tree);
	}
};
var $elm$core$Array$setHelp = F4($elm$core$Array$setHelp$);
var $elm$core$Array$set$ = function (index, value, array) {
	var len = array.a;
	var startShift = array.b;
	var tree = array.c;
	var tail = array.d;
	return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? array : ((_Utils_cmp(
		index,
		$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Array$Array_elm_builtin$(
		len,
		startShift,
		tree,
		A3($elm$core$Elm$JsArray$unsafeSet, $elm$core$Array$bitMask & index, value, tail)) : $elm$core$Array$Array_elm_builtin$(
		len,
		startShift,
		$elm$core$Array$setHelp$(startShift, index, value, tree),
		tail));
};
var $elm$core$Array$set = F3($elm$core$Array$set$);
var $elm$core$Maybe$withDefault$ = function (_default, maybe) {
	if (!maybe.$) {
		var value = maybe.a;
		return value;
	} else {
		return _default;
	}
};
var $elm$core$Maybe$withDefault = F2($elm$core$Maybe$withDefault$);
var $author$project$Shapes$gridOf = function (points) {
	var cells = $elm$core$List$map$(
		function (p) {
			return _Utils_Tuple3(
				$author$project$Shapes$cellOf(p.gQ.m),
				$author$project$Shapes$cellOf(p.gQ.n),
				$author$project$Shapes$cellOf(p.gQ.o));
		},
		$elm$core$Array$toList(points));
	var bounds = function (get) {
		return _Utils_Tuple2(
			$elm$core$Maybe$withDefault$(
				0,
				$elm$core$List$minimum(
					$elm$core$List$map$(get, cells))),
			$elm$core$Maybe$withDefault$(
				-1,
				$elm$core$List$maximum(
					$elm$core$List$map$(get, cells))));
	};
	var _v0 = _Utils_Tuple3(
		bounds(
			function (_v4) {
				var x = _v4.a;
				return x;
			}),
		bounds(
			function (_v5) {
				var y = _v5.b;
				return y;
			}),
		bounds(
			function (_v6) {
				var z = _v6.c;
				return z;
			}));
	var _v1 = _v0.a;
	var x0 = _v1.a;
	var x1 = _v1.b;
	var _v2 = _v0.b;
	var y0 = _v2.a;
	var y1 = _v2.b;
	var _v3 = _v0.c;
	var z0 = _v3.a;
	var z1 = _v3.b;
	var _v7 = _Utils_Tuple3((x1 - x0) + 1, (y1 - y0) + 1, (z1 - z0) + 1);
	var nx = _v7.a;
	var ny = _v7.b;
	var nz = _v7.c;
	return {
		V: $elm$core$List$foldl$(
			F2(
				function (_v8, _v9) {
					var x = _v8.a;
					var y = _v8.b;
					var z = _v8.c;
					var index = _v9.a;
					var grid = _v9.b;
					var at = ((((x - x0) * ny) + (y - y0)) * nz) + (z - z0);
					return _Utils_Tuple2(
						index + 1,
						$elm$core$Array$set$(
							at,
							A2(
								$elm$core$List$cons,
								index,
								$elm$core$Maybe$withDefault$(
									_List_Nil,
									$elm$core$Array$get$(at, grid))),
							grid));
				}),
			_Utils_Tuple2(
				0,
				$elm$core$Array$repeat$((nx * ny) * nz, _List_Nil)),
			cells).b,
		b_: nx,
		bD: ny,
		bE: nz,
		cc: x0,
		cd: y0,
		ce: z0
	};
};
var $elm$core$Array$length = function (_v0) {
	var len = _v0.a;
	return len;
};
var $ianmackenzie$elm_geometry$Point3d$toMeters = function (_v0) {
	var coordinates = _v0;
	return coordinates;
};
var $author$project$Surface$fromPoint = function (point) {
	return $ianmackenzie$elm_geometry$Point3d$toMeters(point);
};
var $author$project$Surface$getPiece$ = function (index, _v0) {
	var surface = _v0;
	return $elm$core$Array$get$(index, surface.A);
};
var $author$project$Surface$getPiece = F2($author$project$Surface$getPiece$);
var $elm$core$Basics$atan2 = _Basics_atan2;
var $elm$core$Basics$cos = _Basics_cos;
var $author$project$Surface$dot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$Surface$dot = F2($author$project$Surface$dot$);
var $elm$core$Basics$pi = _Basics_pi;
var $elm$core$Basics$clamp$ = function (low, high, number) {
	return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
};
var $elm$core$Basics$clamp = F3($elm$core$Basics$clamp$);
var $author$project$Surface$wrapAngle = function (angle) {
	var turns = $elm$core$Basics$floor(angle / (2 * $elm$core$Basics$pi));
	return angle - ((turns * 2) * $elm$core$Basics$pi);
};
var $author$project$Surface$closestOnSegment$ = function (segment, r, h) {
	if (!segment.$) {
		var dh = segment.a.aP;
		var dr = segment.a.N;
		var h0 = segment.a.cX;
		var r0 = segment.a.b2;
		var len = segment.a.af;
		var s0 = segment.a.ak;
		return s0 + $elm$core$Basics$clamp$(0, len, ((r - r0) * dr) + ((h - h0) * dh));
	} else {
		var dir = segment.a.cj;
		var a0 = segment.a.S;
		var radius = segment.a.p;
		var ch = segment.a.cg;
		var cr = segment.a.bM;
		var len = segment.a.af;
		var s0 = segment.a.ak;
		var swept = len / radius;
		var relative = $author$project$Surface$wrapAngle(
			dir * (A2($elm$core$Basics$atan2, h - ch, r - cr) - a0));
		return (_Utils_cmp(relative, swept) < 1) ? (s0 + (relative * radius)) : ((_Utils_cmp(relative - swept, (2 * $elm$core$Basics$pi) - relative) < 0) ? (s0 + len) : s0);
	}
};
var $author$project$Surface$closestOnSegment = F3($author$project$Surface$closestOnSegment$);
var $author$project$Surface$clampFloat$ = function (low, high, x) {
	return ((x - low) < 0) ? low : (((x - high) > 0) ? high : x);
};
var $author$project$Surface$clampFloat = F3($author$project$Surface$clampFloat$);
var $elm$core$Basics$sin = _Basics_sin;
var $author$project$Surface$segmentAt$ = function (segment, s) {
	if (!segment.$) {
		var dh = segment.a.aP;
		var dr = segment.a.N;
		var h0 = segment.a.cX;
		var r0 = segment.a.b2;
		var len = segment.a.af;
		var s0 = segment.a.ak;
		var t = $author$project$Surface$clampFloat$(0, len, s - s0);
		return {aP: dh, N: dr, bz: h0 + (t * dh), f: r0 + (t * dr)};
	} else {
		var dir = segment.a.cj;
		var a0 = segment.a.S;
		var radius = segment.a.p;
		var ch = segment.a.cg;
		var cr = segment.a.bM;
		var len = segment.a.af;
		var s0 = segment.a.ak;
		var angle = a0 + ((dir * $author$project$Surface$clampFloat$(0, len, s - s0)) / radius);
		return {
			aP: dir * $elm$core$Basics$cos(angle),
			N: (-dir) * $elm$core$Basics$sin(angle),
			bz: ch + (radius * $elm$core$Basics$sin(angle)),
			f: cr + (radius * $elm$core$Basics$cos(angle))
		};
	}
};
var $author$project$Surface$segmentAt = F2($author$project$Surface$segmentAt$);
var $author$project$Surface$closestOnProfile$ = function (feature, r, h) {
	return $elm$core$List$foldl$(
		F2(
			function (segment, _v0) {
				var bestS = _v0.a;
				var bestDistance = _v0.b;
				var s = $author$project$Surface$closestOnSegment$(segment, r, h);
				var p = $author$project$Surface$segmentAt$(segment, s);
				var distance = A2($elm$core$Basics$pow, p.f - r, 2) + A2($elm$core$Basics$pow, p.bz - h, 2);
				return (_Utils_cmp(distance, bestDistance) < 0) ? _Utils_Tuple2(s, distance) : _Utils_Tuple2(bestS, bestDistance);
			}),
		_Utils_Tuple2(0, 1 / 0),
		feature.gX).a;
};
var $author$project$Surface$closestOnProfile = F3($author$project$Surface$closestOnProfile$);
var $author$project$Surface$segLength = function (segment) {
	if (!segment.$) {
		var len = segment.a.af;
		return len;
	} else {
		var len = segment.a.af;
		return len;
	}
};
var $author$project$Surface$segS0 = function (segment) {
	if (!segment.$) {
		var s0 = segment.a.ak;
		return s0;
	} else {
		var s0 = segment.a.ak;
		return s0;
	}
};
var $author$project$Surface$profileAtHelper$ = function (segments, s) {
	profileAtHelper:
	while (true) {
		if (!segments.b) {
			return {aP: 1, N: 0, bz: 0, f: 0};
		} else {
			if (!segments.b.b) {
				var last = segments.a;
				return $author$project$Surface$segmentAt$(last, s);
			} else {
				var first = segments.a;
				var rest = segments.b;
				if ((s - ($author$project$Surface$segS0(first) + $author$project$Surface$segLength(first))) < 0) {
					return $author$project$Surface$segmentAt$(first, s);
				} else {
					var $temp$segments = rest;
					segments = $temp$segments;
					continue profileAtHelper;
				}
			}
		}
	}
};
var $author$project$Surface$profileAtHelper = F2($author$project$Surface$profileAtHelper$);
var $author$project$Surface$profileAt$ = function (feature, s) {
	return $author$project$Surface$profileAtHelper$(feature.gX, s);
};
var $author$project$Surface$profileAt = F2($author$project$Surface$profileAt$);
var $author$project$Surface$profileParamUnclamped$ = function (feature, r, h) {
	var s = $author$project$Surface$closestOnProfile$(feature, r, h);
	var along = function (end) {
		var p = $author$project$Surface$profileAt$(feature, end);
		return (end + ((r - p.f) * p.N)) + ((h - p.bz) * p.aP);
	};
	return (s <= 1.0e-9) ? $elm$core$Basics$min$(
		0,
		along(0)) : ((_Utils_cmp(s, feature.aR - 1.0e-9) > -1) ? $elm$core$Basics$max$(
		feature.aR,
		along(feature.aR)) : s);
};
var $author$project$Surface$profileParamUnclamped = F3($author$project$Surface$profileParamUnclamped$);
var $author$project$Surface$sub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$Surface$sub = F2($author$project$Surface$sub$);
var $author$project$Surface$localCoordinatesUnclamped$ = function (piece, point) {
	if (!piece.$) {
		var flat = piece.a;
		var local = $author$project$Surface$sub$(point, flat.z);
		return {
			cK: $author$project$Surface$dot$(local, flat.a9),
			cM: $author$project$Surface$dot$(local, flat.bb)
		};
	} else {
		var feature = piece.a;
		var local = $author$project$Surface$sub$(point, feature.z);
		var x = $author$project$Surface$dot$(local, feature.az);
		var y = $author$project$Surface$dot$(local, feature.aA);
		var rawTheta = A2($elm$core$Basics$atan2, y, x);
		var theta = function () {
			var _v1 = feature.jg;
			if (!_v1.$) {
				var to = _v1.a.e;
				var from = _v1.a.c;
				var middle = (from + to) / 2;
				return (middle + $author$project$Surface$wrapAngle((rawTheta - middle) + $elm$core$Basics$pi)) - $elm$core$Basics$pi;
			} else {
				return rawTheta;
			}
		}();
		return {
			cK: theta,
			cM: $author$project$Surface$profileParamUnclamped$(
				feature,
				(x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta)),
				$author$project$Surface$dot$(local, feature.an))
		};
	}
};
var $author$project$Surface$localCoordinatesUnclamped = F2($author$project$Surface$localCoordinatesUnclamped$);
var $elm$core$Basics$e = _Basics_e;
var $author$project$Surface$cexp = function (p) {
	var magnitude = A2($elm$core$Basics$pow, $elm$core$Basics$e, p.aj);
	return {
		ad: magnitude * $elm$core$Basics$sin(p.ad),
		aj: magnitude * $elm$core$Basics$cos(p.ad)
	};
};
var $author$project$Surface$cscale$ = function (s, p) {
	return {ad: s * p.ad, aj: s * p.aj};
};
var $author$project$Surface$cscale = F2($author$project$Surface$cscale$);
var $author$project$Surface$maxFloat$ = function (a, b) {
	return ((a - b) > 0) ? a : b;
};
var $author$project$Surface$maxFloat = F2($author$project$Surface$maxFloat$);
var $author$project$Surface$minimumRadius = 1.0e-3;
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $elm$core$Basics$tan = _Basics_tan;
var $author$project$Surface$segmentSigma$ = function (segment, t) {
	if (!segment.$) {
		var dr = segment.a.N;
		var r0 = segment.a.b2;
		return ($elm$core$Basics$abs(dr) < 1.0e-9) ? (t / $author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0)) : (($elm$core$Basics$logBase$(
			$elm$core$Basics$e,
			$author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0 + (t * dr))) - $elm$core$Basics$logBase$(
			$elm$core$Basics$e,
			$author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0))) / dr);
	} else {
		var len = segment.a.af;
		var dir = segment.a.cj;
		var a0 = segment.a.S;
		var radius = segment.a.p;
		var cr = segment.a.bM;
		var antiderivative = function (angle) {
			if ($elm$core$Basics$abs(cr - radius) < 1.0e-9) {
				return $elm$core$Basics$tan(angle / 2);
			} else {
				if ((cr - radius) > 0) {
					var root = $elm$core$Basics$sqrt((cr * cr) - (radius * radius));
					return ((2 * radius) / root) * A2(
						$elm$core$Basics$atan2,
						$elm$core$Basics$sqrt((cr - radius) / (cr + radius)) * $elm$core$Basics$sin(angle / 2),
						$elm$core$Basics$cos(angle / 2));
				} else {
					var x = $elm$core$Basics$clamp$(
						(-1) + 1.0e-9,
						1 - 1.0e-9,
						$elm$core$Basics$sqrt((radius - cr) / (radius + cr)) * $elm$core$Basics$tan(angle / 2));
					var root = $elm$core$Basics$sqrt((radius * radius) - (cr * cr));
					return (radius / root) * $elm$core$Basics$logBase$($elm$core$Basics$e, (1 + x) / (1 - x));
				}
			}
		};
		return dir * (antiderivative(
			a0 + ((dir * $author$project$Surface$clampFloat$(0, len, t)) / radius)) - antiderivative(a0));
	}
};
var $author$project$Surface$segmentSigma = F2($author$project$Surface$segmentSigma$);
var $author$project$Surface$sigmaAt$ = function (feature, s) {
	var inside = $elm$core$List$foldl$(
		F2(
			function (segment, total) {
				var s0 = $author$project$Surface$segS0(segment);
				return total + $author$project$Surface$segmentSigma$(
					segment,
					$author$project$Surface$clampFloat$(
						0,
						$author$project$Surface$segLength(segment),
						s - s0));
			}),
		0,
		feature.gX);
	var beyond = (s < 0) ? (s / $author$project$Surface$maxFloat$(
		$author$project$Surface$minimumRadius,
		$author$project$Surface$profileAt$(feature, 0).f)) : (((s - feature.aR) > 0) ? ((s - feature.aR) / $author$project$Surface$maxFloat$(
		$author$project$Surface$minimumRadius,
		$author$project$Surface$profileAt$(feature, feature.aR).f)) : 0);
	return inside + beyond;
};
var $author$project$Surface$sigmaAt = F2($author$project$Surface$sigmaAt$);
var $author$project$Surface$localChart$ = function (piece, a, b) {
	if (!piece.$) {
		return {ad: b, aj: a};
	} else {
		var feature = piece.a;
		return {
			ad: feature.aN * a,
			aj: $author$project$Surface$sigmaAt$(feature, b)
		};
	}
};
var $author$project$Surface$localChart = F3($author$project$Surface$localChart$);
var $author$project$Surface$tolerance = 1.0e-4;
var $author$project$Surface$pieceExponent = function (piece) {
	if (!piece.$) {
		return 0;
	} else {
		var feature = piece.a;
		return (($elm$core$Basics$abs(
			$author$project$Surface$profileAt$(feature, feature.aR).f) - $author$project$Surface$tolerance) < 0) ? (-1) : (((($elm$core$Basics$abs(
			$author$project$Surface$profileAt$(feature, 0).f) - $author$project$Surface$tolerance) < 0) || _Utils_eq(feature.jg, $elm$core$Maybe$Nothing)) ? 1 : 0);
	}
};
var $author$project$Surface$mapChart$ = function (piece, a, b) {
	var exponent = $author$project$Surface$pieceExponent(piece);
	var chart = $author$project$Surface$localChart$(piece, a, b);
	return (!exponent) ? chart : $author$project$Surface$cexp(
		$author$project$Surface$cscale$(exponent, chart));
};
var $author$project$Surface$mapChart = F3($author$project$Surface$mapChart$);
var $author$project$Surface$chartCoordinate$ = function (surface, pieceIndex, point) {
	var _v0 = $author$project$Surface$getPiece$(pieceIndex, surface);
	if (!_v0.$) {
		var piece = _v0.a;
		var local = $author$project$Surface$localCoordinatesUnclamped$(
			piece,
			$author$project$Surface$fromPoint(point));
		return $author$project$Surface$mapChart$(piece, local.cK, local.cM);
	} else {
		return {ad: 0, aj: 0};
	}
};
var $author$project$Surface$chartCoordinate = F3($author$project$Surface$chartCoordinate$);
var $ianmackenzie$elm_geometry$Geometry$Types$Point3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Point3d$meters$ = function (x, y, z) {
	return {m: x, n: y, o: z};
};
var $ianmackenzie$elm_geometry$Point3d$meters = F3($ianmackenzie$elm_geometry$Point3d$meters$);
var $elm$core$Maybe$map$ = function (f, maybe) {
	if (!maybe.$) {
		var value = maybe.a;
		return $elm$core$Maybe$Just(
			f(value));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$Maybe$map = F2($elm$core$Maybe$map$);
var $author$project$Surface$lengthOf = function (a) {
	return $elm$core$Basics$sqrt(
		$author$project$Surface$dot$(a, a));
};
var $author$project$Surface$vec$ = function (x, y, z) {
	return {m: x, n: y, o: z};
};
var $author$project$Surface$vec = F3($author$project$Surface$vec$);
var $author$project$Surface$boxDistance$ = function (p, box) {
	var outside = F3(
		function (low, high, x) {
			return $author$project$Surface$maxFloat$(
				0,
				$author$project$Surface$maxFloat$(low - x, x - high));
		});
	return $author$project$Surface$lengthOf(
		$author$project$Surface$vec$(
			A3(outside, box.a3.m, box.a2.m, p.m),
			A3(outside, box.a3.n, box.a2.n, p.n),
			A3(outside, box.a3.o, box.a2.o, p.o)));
};
var $author$project$Surface$boxDistance = F2($author$project$Surface$boxDistance$);
var $elm$core$Array$foldl$ = function (func, baseCase, _v0) {
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (!node.$) {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				var values = node.a;
				return A3($elm$core$Elm$JsArray$foldl, func, acc, values);
			}
		});
	return A3(
		$elm$core$Elm$JsArray$foldl,
		func,
		A3($elm$core$Elm$JsArray$foldl, helper, baseCase, tree),
		tail);
};
var $elm$core$Array$foldl = F3($elm$core$Array$foldl$);
var $author$project$Surface$add$ = function (a, b) {
	return {m: a.m + b.m, n: a.n + b.n, o: a.o + b.o};
};
var $author$project$Surface$add = F2($author$project$Surface$add$);
var $author$project$Surface$combine$ = function (a, p, b, q) {
	return {m: (a * p.m) + (b * q.m), n: (a * p.n) + (b * q.n), o: (a * p.o) + (b * q.o)};
};
var $author$project$Surface$combine = F4($author$project$Surface$combine$);
var $author$project$Surface$featurePoint$ = function (feature, theta, s) {
	var radial = $author$project$Surface$combine$(
		$elm$core$Basics$cos(theta),
		feature.az,
		$elm$core$Basics$sin(theta),
		feature.aA);
	var p = $author$project$Surface$profileAt$(feature, s);
	return $author$project$Surface$add$(
		feature.z,
		$author$project$Surface$combine$(p.f, radial, p.bz, feature.an));
};
var $author$project$Surface$featurePoint = F3($author$project$Surface$featurePoint$);
var $author$project$Surface$flatPoint$ = function (flat, a, b) {
	return $author$project$Surface$add$(
		flat.z,
		$author$project$Surface$combine$(a, flat.a9, b, flat.bb));
};
var $author$project$Surface$flatPoint = F3($author$project$Surface$flatPoint$);
var $author$project$Surface$piecePoint$ = function (piece, a, b) {
	if (!piece.$) {
		var flat = piece.a;
		return $author$project$Surface$flatPoint$(flat, a, b);
	} else {
		var feature = piece.a;
		return $author$project$Surface$featurePoint$(feature, a, b);
	}
};
var $author$project$Surface$piecePoint = F3($author$project$Surface$piecePoint$);
var $author$project$Surface$clampTheta$ = function (feature, theta) {
	var _v0 = feature.jg;
	if (!_v0.$) {
		var to = _v0.a.e;
		var from = _v0.a.c;
		var relative = $author$project$Surface$wrapAngle(theta - from);
		return (_Utils_cmp(relative, to - from) < 1) ? (from + relative) : ((_Utils_cmp(relative - (to - from), (2 * $elm$core$Basics$pi) - relative) < 0) ? to : from);
	} else {
		return $author$project$Surface$wrapAngle(theta);
	}
};
var $author$project$Surface$clampTheta = F2($author$project$Surface$clampTheta$);
var $author$project$Surface$projectOntoFeature$ = function (feature, point) {
	var local = $author$project$Surface$sub$(point, feature.z);
	var x = $author$project$Surface$dot$(local, feature.az);
	var y = $author$project$Surface$dot$(local, feature.aA);
	var theta = $author$project$Surface$clampTheta$(
		feature,
		A2($elm$core$Basics$atan2, y, x));
	var r = (x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta));
	return _Utils_Tuple2(
		theta,
		$author$project$Surface$closestOnProfile$(
			feature,
			r,
			$author$project$Surface$dot$(local, feature.an)));
};
var $author$project$Surface$projectOntoFeature = F2($author$project$Surface$projectOntoFeature$);
var $author$project$Surface$arcClampAngle$ = function (a0, swept, angle) {
	var dir = (swept < 0) ? (-1) : 1;
	var relative = $author$project$Surface$wrapAngle(dir * (angle - a0));
	return (_Utils_cmp(
		relative,
		$elm$core$Basics$abs(swept)) < 1) ? (a0 + (dir * relative)) : ((_Utils_cmp(
		relative - $elm$core$Basics$abs(swept),
		(2 * $elm$core$Basics$pi) - relative) < 0) ? (a0 + swept) : a0);
};
var $author$project$Surface$arcClampAngle = F3($author$project$Surface$arcClampAngle$);
var $author$project$Surface$closestOnEdge2d$ = function (edge, a, b) {
	if (!edge.$) {
		var by = edge.a.aX;
		var bx = edge.a.aW;
		var ay = edge.a.aM;
		var ax = edge.a.aL;
		var dy = by - ay;
		var dx = bx - ax;
		var t = $elm$core$Basics$clamp$(0, 1, (((a - ax) * dx) + ((b - ay) * dy)) / ((dx * dx) + (dy * dy)));
		return _Utils_Tuple2(ax + (t * dx), ay + (t * dy));
	} else {
		var swept = edge.a.aI;
		var a0 = edge.a.S;
		var r = edge.a.f;
		var cy = edge.a.aw;
		var cx = edge.a.av;
		var angle = $author$project$Surface$arcClampAngle$(
			a0,
			swept,
			A2($elm$core$Basics$atan2, b - cy, a - cx));
		return _Utils_Tuple2(
			cx + (r * $elm$core$Basics$cos(angle)),
			cy + (r * $elm$core$Basics$sin(angle)));
	}
};
var $author$project$Surface$closestOnEdge2d = F3($author$project$Surface$closestOnEdge2d$);
var $elm$core$Basics$modBy = _Basics_modBy;
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Surface$onArc$ = function (a0, swept, angle) {
	var dir = (swept < 0) ? (-1) : 1;
	return ($author$project$Surface$wrapAngle(dir * (angle - a0)) - $elm$core$Basics$abs(swept)) <= 1.0e-9;
};
var $author$project$Surface$onArc = F3($author$project$Surface$onArc$);
var $author$project$Surface$rayCrossings$ = function (edge, a, b) {
	if (!edge.$) {
		var by = edge.a.aX;
		var bx = edge.a.aW;
		var ay = edge.a.aM;
		var ax = edge.a.aL;
		return ((!_Utils_eq(
			_Utils_cmp(ay, b) > 0,
			_Utils_cmp(by, b) > 0)) && (_Utils_cmp(a, ax + (((b - ay) / (by - ay)) * (bx - ax))) < 0)) ? 1 : 0;
	} else {
		var swept = edge.a.aI;
		var a0 = edge.a.S;
		var r = edge.a.f;
		var cy = edge.a.aw;
		var cx = edge.a.av;
		var dy = b - cy;
		if (_Utils_cmp(
			$elm$core$Basics$abs(dy),
			r) > -1) {
			return 0;
		} else {
			var dx = $elm$core$Basics$sqrt((r * r) - (dy * dy));
			var count = function (x) {
				return ((_Utils_cmp(x, a) > 0) && $author$project$Surface$onArc$(
					a0,
					swept,
					A2($elm$core$Basics$atan2, dy, x - cx))) ? 1 : 0;
			};
			return count(cx + dx) + count(cx - dx);
		}
	}
};
var $author$project$Surface$rayCrossings = F3($author$project$Surface$rayCrossings$);
var $author$project$Surface$insideFlat$ = function (flat, a, b) {
	return 1 === A2(
		$elm$core$Basics$modBy,
		2,
		$elm$core$Array$foldl$(
			F2(
				function (edge, count) {
					return count + $author$project$Surface$rayCrossings$(edge, a, b);
				}),
			0,
			flat.bS));
};
var $author$project$Surface$insideFlat = F3($author$project$Surface$insideFlat$);
var $author$project$Surface$projectOntoFlat$ = function (flat, point) {
	var local = $author$project$Surface$sub$(point, flat.z);
	var b = $author$project$Surface$dot$(local, flat.bb);
	var a = $author$project$Surface$dot$(local, flat.a9);
	return $author$project$Surface$insideFlat$(flat, a, b) ? _Utils_Tuple2(a, b) : $elm$core$Array$foldl$(
		F2(
			function (edge, _v0) {
				var best = _v0.a;
				var bestDistance = _v0.b;
				var _v1 = $author$project$Surface$closestOnEdge2d$(edge, a, b);
				var ca = _v1.a;
				var cb = _v1.b;
				var distance = A2($elm$core$Basics$pow, ca - a, 2) + A2($elm$core$Basics$pow, cb - b, 2);
				return (_Utils_cmp(distance, bestDistance) < 0) ? _Utils_Tuple2(
					_Utils_Tuple2(ca, cb),
					distance) : _Utils_Tuple2(best, bestDistance);
			}),
		_Utils_Tuple2(
			_Utils_Tuple2(a, b),
			1 / 0),
		flat.bS).a;
};
var $author$project$Surface$projectOntoFlat = F2($author$project$Surface$projectOntoFlat$);
var $author$project$Surface$projectOntoPiece$ = function (piece, point) {
	if (!piece.$) {
		var flat = piece.a;
		return $author$project$Surface$projectOntoFlat$(flat, point);
	} else {
		var feature = piece.a;
		return $author$project$Surface$projectOntoFeature$(feature, point);
	}
};
var $author$project$Surface$projectOntoPiece = F2($author$project$Surface$projectOntoPiece$);
var $author$project$Surface$nearest$ = function (point, _v0) {
	var surface = _v0;
	var p = $author$project$Surface$fromPoint(point);
	var closest = F2(
		function (piece, index) {
			var _v5 = $author$project$Surface$projectOntoPiece$(piece, p);
			var a = _v5.a;
			var b = _v5.b;
			var position = $author$project$Surface$piecePoint$(piece, a, b);
			return _Utils_Tuple2(
				{cK: a, cM: b, aq: index, gQ: position},
				$author$project$Surface$lengthOf(
					$author$project$Surface$sub$(position, p)));
		});
	return $elm$core$Maybe$map$(
		$elm$core$Tuple$first,
		$elm$core$Array$foldl$(
			F2(
				function (piece, _v1) {
					var index = _v1.a;
					var best = _v1.b;
					return _Utils_Tuple2(
						index + 1,
						function () {
							if (!best.$) {
								var _v3 = best.a;
								var bestDistance = _v3.b;
								if (function (d) {
									return (d - bestDistance) >= 0;
								}(
									$elm$core$Maybe$withDefault$(
										0,
										$elm$core$Maybe$map$(
											$author$project$Surface$boxDistance(p),
											$elm$core$Array$get$(index, surface.dF))))) {
									return best;
								} else {
									var _v4 = A2(closest, piece, index);
									var found = _v4.a;
									var distance = _v4.b;
									return ((distance - bestDistance) < 0) ? $elm$core$Maybe$Just(
										_Utils_Tuple2(found, distance)) : best;
								}
							} else {
								return $elm$core$Maybe$Just(
									A2(closest, piece, index));
							}
						}());
				}),
			_Utils_Tuple2(0, $elm$core$Maybe$Nothing),
			surface.A).b);
};
var $author$project$Surface$nearest = F2($author$project$Surface$nearest$);
var $author$project$Surface$nearestPiece$ = function (point, surface) {
	return $elm$core$Maybe$map$(
		function ($) {
			return $.aq;
		},
		$author$project$Surface$nearest$(point, surface));
};
var $author$project$Surface$nearestPiece = F2($author$project$Surface$nearestPiece$);
var $author$project$Shapes$onPiece$ = function (surface, p) {
	var point = $ianmackenzie$elm_geometry$Point3d$meters$(p.m, p.n, p.o);
	var _v0 = $author$project$Surface$nearestPiece$(point, surface);
	if (!_v0.$) {
		var piece = _v0.a;
		return {
			K: $author$project$Surface$chartCoordinate$(surface, piece, point),
			aq: piece,
			gQ: p
		};
	} else {
		return {
			K: {ad: 0, aj: 0},
			aq: -1,
			gQ: p
		};
	}
};
var $author$project$Shapes$onPiece = F2($author$project$Shapes$onPiece$);
var $elm$core$Maybe$andThen$ = function (callback, maybeValue) {
	if (!maybeValue.$) {
		var value = maybeValue.a;
		return callback(value);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$Maybe$andThen = F2($elm$core$Maybe$andThen$);
var $author$project$Surface$featureBasis$ = function (feature, theta, s) {
	var radial = $author$project$Surface$combine$(
		$elm$core$Basics$cos(theta),
		feature.az,
		$elm$core$Basics$sin(theta),
		feature.aA);
	var p = $author$project$Surface$profileAt$(feature, s);
	return {
		ax: $author$project$Surface$combine$(p.N, radial, p.aP, feature.an),
		ay: $author$project$Surface$combine$(
			-$elm$core$Basics$sin(theta),
			feature.az,
			$elm$core$Basics$cos(theta),
			feature.aA),
		s: $author$project$Surface$combine$(p.aP, radial, -p.N, feature.an),
		L: $author$project$Surface$add$(
			feature.z,
			$author$project$Surface$combine$(p.f, radial, p.bz, feature.an))
	};
};
var $author$project$Surface$featureBasis = F3($author$project$Surface$featureBasis$);
var $author$project$Surface$scale$ = function (s, a) {
	return {m: s * a.m, n: s * a.n, o: s * a.o};
};
var $author$project$Surface$scale = F2($author$project$Surface$scale$);
var $author$project$Surface$tangentFrame$ = function (piece, a, b) {
	if (!piece.$) {
		var flat = piece.a;
		return {
			bP: flat.a9,
			bQ: flat.bb,
			s: flat.s,
			L: $author$project$Surface$flatPoint$(flat, a, b)
		};
	} else {
		var feature = piece.a;
		var basis = $author$project$Surface$featureBasis$(feature, a, b);
		return {
			bP: basis.ax,
			bQ: $author$project$Surface$scale$(feature.aN, basis.ay),
			s: basis.s,
			L: basis.L
		};
	}
};
var $author$project$Surface$tangentFrame = F3($author$project$Surface$tangentFrame$);
var $ianmackenzie$elm_geometry$Geometry$Types$Direction3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Direction3d$unsafe = function (components) {
	return components;
};
var $author$project$Surface$toDirection = function (v) {
	return $ianmackenzie$elm_geometry$Direction3d$unsafe(v);
};
var $ianmackenzie$elm_geometry$Point3d$fromMeters = function (coordinates) {
	return coordinates;
};
var $author$project$Surface$toPoint = function (v) {
	return $ianmackenzie$elm_geometry$Point3d$fromMeters(v);
};
var $author$project$Surface$nearestPoint$ = function (point, surface) {
	return $elm$core$Maybe$andThen$(
		function (_v0) {
			var b = _v0.cM;
			var a = _v0.cK;
			var piece = _v0.aq;
			return $elm$core$Maybe$map$(
				function (piece_) {
					var frame = $author$project$Surface$tangentFrame$(piece_, a, b);
					return {
						k: $author$project$Surface$toDirection(frame.s),
						gQ: $author$project$Surface$toPoint(frame.L)
					};
				},
				$author$project$Surface$getPiece$(piece, surface));
		},
		$author$project$Surface$nearest$(point, surface));
};
var $author$project$Surface$nearestPoint = F2($author$project$Surface$nearestPoint$);
var $author$project$Shapes$snap$ = function (surface, p) {
	var _v0 = $author$project$Surface$nearestPoint$(
		$ianmackenzie$elm_geometry$Point3d$meters$(p.m, p.n, p.o),
		surface);
	if (!_v0.$) {
		var position = _v0.a.gQ;
		return $ianmackenzie$elm_geometry$Point3d$toMeters(position);
	} else {
		return p;
	}
};
var $author$project$Shapes$snap = F2($author$project$Shapes$snap$);
var $author$project$Shapes$wallStep = 0.1;
var $author$project$Shapes$addWalls$ = function (surface, walls, shapes) {
	var _v0 = $elm$core$List$foldl$(
		F2(
			function (wall, _v1) {
				var pointsSoFar = _v1.a;
				var wallsSoFar = _v1.b;
				var added = $elm$core$List$map$(
					A2(
						$elm$core$Basics$composeR,
						$author$project$Shapes$snap(surface),
						$author$project$Shapes$onPiece(surface)),
					$author$project$Shapes$alongWall$(
						$author$project$Shapes$wallStep,
						$elm$core$List$map$($author$project$Shapes$fromTuple, wall)));
				return _Utils_Tuple2(
					$elm$core$Array$append$(
						pointsSoFar,
						$elm$core$Array$fromList(added)),
					A2(
						$elm$core$List$cons,
						$elm$core$List$range$(
							$elm$core$Array$length(pointsSoFar),
							($elm$core$Array$length(pointsSoFar) + $elm$core$List$length(added)) - 1),
						wallsSoFar));
			}),
		_Utils_Tuple2(shapes.fn, shapes.jE),
		walls);
	var allPoints = _v0.a;
	var wallIndices = _v0.b;
	return _Utils_update(
		shapes,
		{
			bU: $author$project$Shapes$gridOf(allPoints),
			fn: allPoints,
			jE: wallIndices
		});
};
var $author$project$Shapes$addWalls = F3($author$project$Shapes$addWalls$);
var $elm$core$Elm$JsArray$map = _JsArray_map;
var $elm$core$Array$map$ = function (func, _v0) {
	var len = _v0.a;
	var startShift = _v0.b;
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = function (node) {
		if (!node.$) {
			var subTree = node.a;
			return $elm$core$Array$SubTree(
				A2($elm$core$Elm$JsArray$map, helper, subTree));
		} else {
			var values = node.a;
			return $elm$core$Array$Leaf(
				A2($elm$core$Elm$JsArray$map, func, values));
		}
	};
	return $elm$core$Array$Array_elm_builtin$(
		len,
		startShift,
		A2($elm$core$Elm$JsArray$map, helper, tree),
		A2($elm$core$Elm$JsArray$map, func, tail));
};
var $elm$core$Array$map = F2($elm$core$Array$map$);
var $author$project$Shapes$pavingEdge = 0.2;
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get$ = function (targetKey, dict) {
	get:
	while (true) {
		if (dict.$ === -2) {
			return $elm$core$Maybe$Nothing;
		} else {
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			var _v1 = A2($elm$core$Basics$compare, targetKey, key);
			switch (_v1) {
				case 0:
					var $temp$dict = left;
					dict = $temp$dict;
					continue get;
				case 1:
					return $elm$core$Maybe$Just(value);
				default:
					var $temp$dict = right;
					dict = $temp$dict;
					continue get;
			}
		}
	}
};
var $elm$core$Dict$get = F2($elm$core$Dict$get$);
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin$ = function (a, b, c, d, e) {
	return {$: -1, a: a, b: b, c: c, d: d, e: e};
};
var $elm$core$Dict$RBNode_elm_builtin = F5($elm$core$Dict$RBNode_elm_builtin$);
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance$ = function (color, key, value, left, right) {
	if ((right.$ === -1) && (!right.a)) {
		var _v1 = right.a;
		var rK = right.b;
		var rV = right.c;
		var rLeft = right.d;
		var rRight = right.e;
		if ((left.$ === -1) && (!left.a)) {
			var _v3 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return $elm$core$Dict$RBNode_elm_builtin$(
				0,
				key,
				value,
				$elm$core$Dict$RBNode_elm_builtin$(1, lK, lV, lLeft, lRight),
				$elm$core$Dict$RBNode_elm_builtin$(1, rK, rV, rLeft, rRight));
		} else {
			return $elm$core$Dict$RBNode_elm_builtin$(
				color,
				rK,
				rV,
				$elm$core$Dict$RBNode_elm_builtin$(0, key, value, left, rLeft),
				rRight);
		}
	} else {
		if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
			var _v5 = left.a;
			var lK = left.b;
			var lV = left.c;
			var _v6 = left.d;
			var _v7 = _v6.a;
			var llK = _v6.b;
			var llV = _v6.c;
			var llLeft = _v6.d;
			var llRight = _v6.e;
			var lRight = left.e;
			return $elm$core$Dict$RBNode_elm_builtin$(
				0,
				lK,
				lV,
				$elm$core$Dict$RBNode_elm_builtin$(1, llK, llV, llLeft, llRight),
				$elm$core$Dict$RBNode_elm_builtin$(1, key, value, lRight, right));
		} else {
			return $elm$core$Dict$RBNode_elm_builtin$(color, key, value, left, right);
		}
	}
};
var $elm$core$Dict$balance = F5($elm$core$Dict$balance$);
var $elm$core$Dict$insertHelp$ = function (key, value, dict) {
	if (dict.$ === -2) {
		return $elm$core$Dict$RBNode_elm_builtin$(0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
	} else {
		var nColor = dict.a;
		var nKey = dict.b;
		var nValue = dict.c;
		var nLeft = dict.d;
		var nRight = dict.e;
		var _v1 = A2($elm$core$Basics$compare, key, nKey);
		switch (_v1) {
			case 0:
				return $elm$core$Dict$balance$(
					nColor,
					nKey,
					nValue,
					$elm$core$Dict$insertHelp$(key, value, nLeft),
					nRight);
			case 1:
				return $elm$core$Dict$RBNode_elm_builtin$(nColor, nKey, value, nLeft, nRight);
			default:
				return $elm$core$Dict$balance$(
					nColor,
					nKey,
					nValue,
					nLeft,
					$elm$core$Dict$insertHelp$(key, value, nRight));
		}
	}
};
var $elm$core$Dict$insertHelp = F3($elm$core$Dict$insertHelp$);
var $elm$core$Dict$insert$ = function (key, value, dict) {
	var _v0 = $elm$core$Dict$insertHelp$(key, value, dict);
	if ((_v0.$ === -1) && (!_v0.a)) {
		var _v1 = _v0.a;
		var k = _v0.b;
		var v = _v0.c;
		var l = _v0.d;
		var r = _v0.e;
		return $elm$core$Dict$RBNode_elm_builtin$(1, k, v, l, r);
	} else {
		var x = _v0;
		return x;
	}
};
var $elm$core$Dict$insert = F3($elm$core$Dict$insert$);
var $elm$core$Maybe$map2$ = function (func, ma, mb) {
	if (ma.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var a = ma.a;
		if (mb.$ === 1) {
			return $elm$core$Maybe$Nothing;
		} else {
			var b = mb.a;
			return $elm$core$Maybe$Just(
				A2(func, a, b));
		}
	}
};
var $elm$core$Maybe$map2 = F3($elm$core$Maybe$map2$);
var $elm$core$Basics$not = _Basics_not;
var $elm$core$Array$push$ = function (a, array) {
	var tail = array.d;
	return $elm$core$Array$unsafeReplaceTail$(
		A2($elm$core$Elm$JsArray$push, a, tail),
		array);
};
var $elm$core$Array$push = F2($elm$core$Array$push$);
var $author$project$Shapes$split$ = function (tooLong, toPoint, position, _v0, state) {
	var i = _v0.a;
	var j = _v0.b;
	var k = _v0.c;
	var point = function (index) {
		return $elm$core$Array$get$(index, state.fn);
	};
	var isTooLong = F2(
		function (a, b) {
			return $elm$core$Maybe$withDefault$(
				false,
				$elm$core$Maybe$map2$(
					tooLong,
					point(a),
					point(b)));
		});
	var at = function (index) {
		return $elm$core$Maybe$withDefault$(
			{m: 0, n: 0, o: 0},
			$elm$core$Maybe$map$(
				position,
				point(index)));
	};
	var dij = $author$project$Shapes$distance$(
		at(i),
		at(j));
	var djk = $author$project$Shapes$distance$(
		at(j),
		at(k));
	var dki = $author$project$Shapes$distance$(
		at(k),
		at(i));
	var halve = F3(
		function (a, b, c) {
			var key = _Utils_Tuple2(
				$elm$core$Basics$min$(a, b),
				$elm$core$Basics$max$(a, b));
			var _v1 = function () {
				var _v2 = $elm$core$Dict$get$(key, state.bZ);
				if (!_v2.$) {
					var existing = _v2.a;
					return _Utils_Tuple2(existing, state);
				} else {
					var index = $elm$core$Array$length(state.fn);
					return _Utils_Tuple2(
						index,
						_Utils_update(
							state,
							{
								bZ: $elm$core$Dict$insert$(key, index, state.bZ),
								fn: $elm$core$Array$push$(
									toPoint(
										$author$project$Shapes$lerp$(
											0.5,
											at(a),
											at(b))),
									state.fn)
							}));
				}
			}();
			var m = _v1.a;
			var withMidpoint = _v1.b;
			return $author$project$Shapes$split$(
				tooLong,
				toPoint,
				position,
				_Utils_Tuple3(m, b, c),
				$author$project$Shapes$split$(
					tooLong,
					toPoint,
					position,
					_Utils_Tuple3(a, m, c),
					withMidpoint));
		});
	return (!(A2(isTooLong, i, j) || (A2(isTooLong, j, k) || A2(isTooLong, k, i)))) ? _Utils_update(
		state,
		{
			aJ: A2(
				$elm$core$List$cons,
				_Utils_Tuple3(i, j, k),
				state.aJ)
		}) : (((_Utils_cmp(dij, djk) > -1) && (_Utils_cmp(dij, dki) > -1)) ? A3(halve, i, j, k) : ((_Utils_cmp(djk, dki) > -1) ? A3(halve, j, k, i) : A3(halve, k, i, j)));
};
var $author$project$Shapes$split = F5($author$project$Shapes$split$);
var $author$project$Shapes$splitPavings$ = function (tooLong, toPoint, position, pavings) {
	return $elm$core$List$foldl$(
		F2(
			function (paving, _v0) {
				var pointsSoFar = _v0.a;
				var trianglesSoFar = _v0.b;
				var withCorners = $elm$core$Array$append$(
					pointsSoFar,
					$elm$core$Array$fromList(
						$elm$core$List$map$(
							A2($elm$core$Basics$composeR, $author$project$Shapes$fromTuple, toPoint),
							paving.fn)));
				var offset = $elm$core$Array$length(pointsSoFar);
				return function (state) {
					return _Utils_Tuple2(state.fn, state.aJ);
				}(
					$elm$core$List$foldl$(
						F2(
							function (_v1, state) {
								var i = _v1.a;
								var j = _v1.b;
								var k = _v1.c;
								return $author$project$Shapes$split$(
									tooLong,
									toPoint,
									position,
									_Utils_Tuple3(i + offset, j + offset, k + offset),
									state);
							}),
						{bZ: $elm$core$Dict$empty, fn: withCorners, aJ: trianglesSoFar},
						paving.aJ));
			}),
		_Utils_Tuple2($elm$core$Array$empty, _List_Nil),
		pavings);
};
var $author$project$Shapes$splitPavings = F4($author$project$Shapes$splitPavings$);
var $author$project$Shapes$prepare$ = function (surface, walls, pavings) {
	var _v0 = $author$project$Shapes$splitPavings$(
		F2(
			function (p, q) {
				return ($author$project$Shapes$distance$(p, q) - $author$project$Shapes$pavingEdge) > 0;
			}),
		$author$project$Shapes$snap(surface),
		$elm$core$Basics$identity,
		pavings);
	var points = _v0.a;
	var triangles = _v0.b;
	var shapePoints = $elm$core$Array$map$(
		$author$project$Shapes$onPiece(surface),
		points);
	return $author$project$Shapes$addWalls$(
		surface,
		walls,
		{
			bU: $author$project$Shapes$gridOf(shapePoints),
			iM: triangles,
			fn: shapePoints,
			jE: _List_Nil
		});
};
var $author$project$Shapes$prepare = F3($author$project$Shapes$prepare$);
var $author$project$Surface$FeaturePiece = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$FlatPiece = function (a) {
	return {$: 0, a: a};
};
var $author$project$Surface$Surface = $elm$core$Basics$identity;
var $author$project$Surface$boxStepAngle = $elm$core$Basics$pi / 24;
var $elm$core$List$append$ = function (xs, ys) {
	if (!ys.b) {
		return xs;
	} else {
		return $elm$core$List$foldr$($elm$core$List$cons, ys, xs);
	}
};
var $elm$core$List$append = F2($elm$core$List$append$);
var $elm$core$List$concat = function (lists) {
	return $elm$core$List$foldr$($elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap$ = function (f, list) {
	return $elm$core$List$concat(
		$elm$core$List$map$(f, list));
};
var $elm$core$List$concatMap = F2($elm$core$List$concatMap$);
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Surface$minFloat$ = function (a, b) {
	return ((a - b) < 0) ? a : b;
};
var $author$project$Surface$minFloat = F2($author$project$Surface$minFloat$);
var $author$project$Surface$cross$ = function (a, b) {
	return {m: (a.n * b.o) - (a.o * b.n), n: (a.o * b.m) - (a.m * b.o), o: (a.m * b.n) - (a.n * b.m)};
};
var $author$project$Surface$cross = F2($author$project$Surface$cross$);
var $author$project$Surface$meshTriangle$ = function (a, b, c, acc) {
	var facing = $author$project$Surface$cross$(
		$author$project$Surface$sub$(b.gQ, a.gQ),
		$author$project$Surface$sub$(c.gQ, a.gQ));
	var outward = $author$project$Surface$dot$(
		facing,
		$author$project$Surface$add$(
			a.k,
			$author$project$Surface$add$(b.k, c.k)));
	return (($author$project$Surface$lengthOf(facing) - 1.0e-12) < 0) ? acc : ((outward > 0) ? A2(
		$elm$core$List$cons,
		_Utils_Tuple3(a, b, c),
		acc) : A2(
		$elm$core$List$cons,
		_Utils_Tuple3(a, c, b),
		acc));
};
var $author$project$Surface$meshTriangle = F4($author$project$Surface$meshTriangle$);
var $author$project$Surface$stepsFor$ = function (maxStepAngle, angle) {
	return $elm$core$Basics$max$(
		1,
		$elm$core$Basics$ceiling(
			($elm$core$Basics$abs(angle) / maxStepAngle) - 1.0e-9));
};
var $author$project$Surface$stepsFor = F2($author$project$Surface$stepsFor$);
var $author$project$Surface$sweepRange = function (feature) {
	var _v0 = feature.jg;
	if (!_v0.$) {
		var to = _v0.a.e;
		var from = _v0.a.c;
		return _Utils_Tuple2(from, to);
	} else {
		return _Utils_Tuple2(0, 2 * $elm$core$Basics$pi);
	}
};
var $author$project$Surface$tessellateFeature$ = function (maxStepAngle, feature) {
	var vertexAt = F2(
		function (theta, s) {
			var basis = $author$project$Surface$featureBasis$(feature, theta, s);
			return {k: basis.s, gQ: basis.L};
		});
	var profileSamples = _Utils_ap(
		$elm$core$List$concatMap$(
			function (segment) {
				if (!segment.$) {
					var s0 = segment.a.ak;
					return _List_fromArray(
						[s0]);
				} else {
					var radius = segment.a.p;
					var len = segment.a.af;
					var s0 = segment.a.ak;
					var steps = $author$project$Surface$stepsFor$(maxStepAngle, len / radius);
					return $elm$core$List$map$(
						function (j) {
							return s0 + ((len * j) / steps);
						},
						$elm$core$List$range$(0, steps - 1));
				}
			},
			feature.gX),
		_List_fromArray(
			[feature.aR]));
	var between = F3(
		function (rowA, rowB, acc) {
			between:
			while (true) {
				var _v0 = _Utils_Tuple2(rowA, rowB);
				if (((_v0.a.b && _v0.a.b.b) && _v0.b.b) && _v0.b.b.b) {
					var _v1 = _v0.a;
					var a0 = _v1.a;
					var restA = _v1.b;
					var a1 = restA.a;
					var _v2 = _v0.b;
					var b0 = _v2.a;
					var restB = _v2.b;
					var b1 = restB.a;
					var $temp$rowA = restA,
						$temp$rowB = restB,
						$temp$acc = $author$project$Surface$meshTriangle$(
						a0,
						a1,
						b1,
						$author$project$Surface$meshTriangle$(a0, b1, b0, acc));
					rowA = $temp$rowA;
					rowB = $temp$rowB;
					acc = $temp$acc;
					continue between;
				} else {
					return acc;
				}
			}
		});
	var allBetween = F2(
		function (remaining, acc) {
			allBetween:
			while (true) {
				if (remaining.b && remaining.b.b) {
					var rowA = remaining.a;
					var rest = remaining.b;
					var rowB = rest.a;
					var $temp$remaining = rest,
						$temp$acc = A3(between, rowA, rowB, acc);
					remaining = $temp$remaining;
					acc = $temp$acc;
					continue allBetween;
				} else {
					return acc;
				}
			}
		});
	var _v4 = $author$project$Surface$sweepRange(feature);
	var from = _v4.a;
	var to = _v4.b;
	var thetaSteps = $author$project$Surface$stepsFor$(maxStepAngle, to - from);
	var thetas = $elm$core$List$map$(
		function (i) {
			return from + (((to - from) * i) / thetaSteps);
		},
		$elm$core$List$range$(0, thetaSteps));
	var rows = $elm$core$List$map$(
		function (s) {
			return $elm$core$List$map$(
				function (theta) {
					return A2(vertexAt, theta, s);
				},
				thetas);
		},
		profileSamples);
	return A2(allBetween, rows, _List_Nil);
};
var $author$project$Surface$tessellateFeature = F2($author$project$Surface$tessellateFeature$);
var $author$project$Surface$distance2$ = function (p, q) {
	return $elm$core$Basics$sqrt(
		A2($elm$core$Basics$pow, p.m - q.m, 2) + A2($elm$core$Basics$pow, p.n - q.n, 2));
};
var $author$project$Surface$distance2 = F2($author$project$Surface$distance2$);
var $elm$core$List$drop$ = function (n, list) {
	drop:
	while (true) {
		if (n <= 0) {
			return list;
		} else {
			if (!list.b) {
				return list;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$n = n - 1,
					$temp$list = xs;
				n = $temp$n;
				list = $temp$list;
				continue drop;
			}
		}
	}
};
var $elm$core$List$drop = F2($elm$core$List$drop$);
var $elm$core$Array$sliceLeft$ = function (from, array) {
	var len = array.a;
	var tree = array.c;
	var tail = array.d;
	if (!from) {
		return array;
	} else {
		if (_Utils_cmp(
			from,
			$elm$core$Array$tailIndex(len)) > -1) {
			return $elm$core$Array$Array_elm_builtin$(
				len - from,
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				A3(
					$elm$core$Elm$JsArray$slice,
					from - $elm$core$Array$tailIndex(len),
					$elm$core$Elm$JsArray$length(tail),
					tail));
		} else {
			var skipNodes = (from / $elm$core$Array$branchFactor) | 0;
			var helper = F2(
				function (node, acc) {
					if (!node.$) {
						var subTree = node.a;
						return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
					} else {
						var leaf = node.a;
						return A2($elm$core$List$cons, leaf, acc);
					}
				});
			var leafNodes = A3(
				$elm$core$Elm$JsArray$foldr,
				helper,
				_List_fromArray(
					[tail]),
				tree);
			var nodesToInsert = $elm$core$List$drop$(skipNodes, leafNodes);
			if (!nodesToInsert.b) {
				return $elm$core$Array$empty;
			} else {
				var head = nodesToInsert.a;
				var rest = nodesToInsert.b;
				var firstSlice = from - (skipNodes * $elm$core$Array$branchFactor);
				var initialBuilder = {
					Q: _List_Nil,
					G: 0,
					M: A3(
						$elm$core$Elm$JsArray$slice,
						firstSlice,
						$elm$core$Elm$JsArray$length(head),
						head)
				};
				return $elm$core$Array$builderToArray$(
					true,
					$elm$core$List$foldl$($elm$core$Array$appendHelpBuilder, initialBuilder, rest));
			}
		}
	}
};
var $elm$core$Array$sliceLeft = F2($elm$core$Array$sliceLeft$);
var $elm$core$Array$fetchNewTail$ = function (shift, end, treeEnd, tree) {
	fetchNewTail:
	while (true) {
		var pos = $elm$core$Array$bitMask & (treeEnd >>> shift);
		var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
		if (!_v0.$) {
			var sub = _v0.a;
			var $temp$shift = shift - $elm$core$Array$shiftStep,
				$temp$tree = sub;
			shift = $temp$shift;
			tree = $temp$tree;
			continue fetchNewTail;
		} else {
			var values = _v0.a;
			return A3($elm$core$Elm$JsArray$slice, 0, $elm$core$Array$bitMask & end, values);
		}
	}
};
var $elm$core$Array$fetchNewTail = F4($elm$core$Array$fetchNewTail$);
var $elm$core$Array$hoistTree$ = function (oldShift, newShift, tree) {
	hoistTree:
	while (true) {
		if ((_Utils_cmp(oldShift, newShift) < 1) || (!$elm$core$Elm$JsArray$length(tree))) {
			return tree;
		} else {
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, 0, tree);
			if (!_v0.$) {
				var sub = _v0.a;
				var $temp$oldShift = oldShift - $elm$core$Array$shiftStep,
					$temp$tree = sub;
				oldShift = $temp$oldShift;
				tree = $temp$tree;
				continue hoistTree;
			} else {
				return tree;
			}
		}
	}
};
var $elm$core$Array$hoistTree = F3($elm$core$Array$hoistTree$);
var $elm$core$Array$sliceTree$ = function (shift, endIdx, tree) {
	var lastPos = $elm$core$Array$bitMask & (endIdx >>> shift);
	var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, lastPos, tree);
	if (!_v0.$) {
		var sub = _v0.a;
		var newSub = $elm$core$Array$sliceTree$(shift - $elm$core$Array$shiftStep, endIdx, sub);
		return (!$elm$core$Elm$JsArray$length(newSub)) ? A3($elm$core$Elm$JsArray$slice, 0, lastPos, tree) : A3(
			$elm$core$Elm$JsArray$unsafeSet,
			lastPos,
			$elm$core$Array$SubTree(newSub),
			A3($elm$core$Elm$JsArray$slice, 0, lastPos + 1, tree));
	} else {
		return A3($elm$core$Elm$JsArray$slice, 0, lastPos, tree);
	}
};
var $elm$core$Array$sliceTree = F3($elm$core$Array$sliceTree$);
var $elm$core$Array$sliceRight$ = function (end, array) {
	var len = array.a;
	var startShift = array.b;
	var tree = array.c;
	var tail = array.d;
	if (_Utils_eq(end, len)) {
		return array;
	} else {
		if (_Utils_cmp(
			end,
			$elm$core$Array$tailIndex(len)) > -1) {
			return $elm$core$Array$Array_elm_builtin$(
				end,
				startShift,
				tree,
				A3($elm$core$Elm$JsArray$slice, 0, $elm$core$Array$bitMask & end, tail));
		} else {
			var endIdx = $elm$core$Array$tailIndex(end);
			var depth = $elm$core$Basics$floor(
				$elm$core$Basics$logBase$(
					$elm$core$Array$branchFactor,
					$elm$core$Basics$max$(1, endIdx - 1)));
			var newShift = $elm$core$Basics$max$(5, depth * $elm$core$Array$shiftStep);
			return $elm$core$Array$Array_elm_builtin$(
				end,
				newShift,
				$elm$core$Array$hoistTree$(
					startShift,
					newShift,
					$elm$core$Array$sliceTree$(startShift, endIdx, tree)),
				$elm$core$Array$fetchNewTail$(startShift, end, endIdx, tree));
		}
	}
};
var $elm$core$Array$sliceRight = F2($elm$core$Array$sliceRight$);
var $elm$core$Array$translateIndex$ = function (index, _v0) {
	var len = _v0.a;
	var posIndex = (index < 0) ? (len + index) : index;
	return (posIndex < 0) ? 0 : ((_Utils_cmp(posIndex, len) > 0) ? len : posIndex);
};
var $elm$core$Array$translateIndex = F2($elm$core$Array$translateIndex$);
var $elm$core$Array$slice$ = function (from, to, array) {
	var correctTo = $elm$core$Array$translateIndex$(to, array);
	var correctFrom = $elm$core$Array$translateIndex$(from, array);
	return (_Utils_cmp(correctFrom, correctTo) > 0) ? $elm$core$Array$empty : $elm$core$Array$sliceLeft$(
		correctFrom,
		$elm$core$Array$sliceRight$(correctTo, array));
};
var $elm$core$Array$slice = F3($elm$core$Array$slice$);
var $author$project$Surface$turn$ = function (a, b, c) {
	return ((b.m - a.m) * (c.n - a.n)) - ((b.n - a.n) * (c.m - a.m));
};
var $author$project$Surface$turn = F3($author$project$Surface$turn$);
var $author$project$Surface$earClipHelper$ = function (points, index, failures, acc) {
	earClipHelper:
	while (true) {
		var count = $elm$core$Array$length(points);
		var at = function (i) {
			return $elm$core$Maybe$withDefault$(
				{m: 0, n: 0},
				$elm$core$Array$get$(
					A2($elm$core$Basics$modBy, count, i),
					points));
		};
		if (count < 3) {
			return acc;
		} else {
			if (_Utils_cmp(failures, count) > 0) {
				return acc;
			} else {
				var same = F2(
					function (p, q) {
						return $author$project$Surface$distance2$(p, q) < 1.0e-9;
					});
				var removeAt = function (i) {
					return $elm$core$Array$append$(
						$elm$core$Array$slice$(0, i, points),
						$elm$core$Array$slice$(i + 1, count, points));
				};
				var c = at(index + 1);
				var b = at(index);
				var a = at(index - 1);
				var inside = function (p) {
					return (!(A2(same, p, a) || (A2(same, p, b) || A2(same, p, c)))) && (($author$project$Surface$turn$(a, b, p) >= 0) && (($author$project$Surface$turn$(b, c, p) >= 0) && ($author$project$Surface$turn$(c, a, p) >= 0)));
				};
				var isEar = ($author$project$Surface$turn$(a, b, c) > 1.0e-12) && (!$elm$core$Array$foldl$(
					F2(
						function (p, found) {
							return found || inside(p);
						}),
					false,
					points));
				if (isEar) {
					var $temp$points = removeAt(
						A2($elm$core$Basics$modBy, count, index)),
						$temp$index = A2(
						$elm$core$Basics$modBy,
						count - 1,
						A2($elm$core$Basics$modBy, count, index)),
						$temp$failures = 0,
						$temp$acc = A2(
						$elm$core$List$cons,
						_Utils_Tuple3(a, b, c),
						acc);
					points = $temp$points;
					index = $temp$index;
					failures = $temp$failures;
					acc = $temp$acc;
					continue earClipHelper;
				} else {
					if ((_Utils_cmp(
						$author$project$Surface$turn$(a, b, c),
						-1.0e-12) > 0) && (($author$project$Surface$turn$(a, b, c) < 1.0e-12) && A2(same, a, c))) {
						var $temp$points = removeAt(
							A2($elm$core$Basics$modBy, count, index)),
							$temp$index = A2(
							$elm$core$Basics$modBy,
							count - 1,
							A2($elm$core$Basics$modBy, count, index)),
							$temp$failures = 0;
						points = $temp$points;
						index = $temp$index;
						failures = $temp$failures;
						continue earClipHelper;
					} else {
						var $temp$index = A2($elm$core$Basics$modBy, count, index + 1),
							$temp$failures = failures + 1;
						index = $temp$index;
						failures = $temp$failures;
						continue earClipHelper;
					}
				}
			}
		}
	}
};
var $author$project$Surface$earClipHelper = F4($author$project$Surface$earClipHelper$);
var $author$project$Surface$earClip = function (loop) {
	return $author$project$Surface$earClipHelper$(
		$elm$core$Array$fromList(loop),
		0,
		0,
		_List_Nil);
};
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Surface$flatLoops$ = function (maxStepAngle, flat) {
	var startOf = function (edge) {
		if (!edge.$) {
			var ay = edge.a.aM;
			var ax = edge.a.aL;
			return {m: ax, n: ay};
		} else {
			var a0 = edge.a.S;
			var r = edge.a.f;
			var cy = edge.a.aw;
			var cx = edge.a.av;
			return {
				m: cx + (r * $elm$core$Basics$cos(a0)),
				n: cy + (r * $elm$core$Basics$sin(a0))
			};
		}
	};
	var pointsOf = function (edge) {
		if (!edge.$) {
			var ay = edge.a.aM;
			var ax = edge.a.aL;
			return _List_fromArray(
				[
					{m: ax, n: ay}
				]);
		} else {
			var swept = edge.a.aI;
			var a0 = edge.a.S;
			var r = edge.a.f;
			var cy = edge.a.aw;
			var cx = edge.a.av;
			var steps = $author$project$Surface$stepsFor$(maxStepAngle, swept);
			return $elm$core$List$map$(
				function (i) {
					var angle = a0 + ((swept * i) / steps);
					return {
						m: cx + (r * $elm$core$Basics$cos(angle)),
						n: cy + (r * $elm$core$Basics$sin(angle))
					};
				},
				$elm$core$List$range$(0, steps - 1));
		}
	};
	var endOf = function (edge) {
		if (!edge.$) {
			var by = edge.a.aX;
			var bx = edge.a.aW;
			return {m: bx, n: by};
		} else {
			var swept = edge.a.aI;
			var a0 = edge.a.S;
			var r = edge.a.f;
			var cy = edge.a.aw;
			var cx = edge.a.av;
			return {
				m: cx + (r * $elm$core$Basics$cos(a0 + swept)),
				n: cy + (r * $elm$core$Basics$sin(a0 + swept))
			};
		}
	};
	var go = F4(
		function (edges, loopStart, current, loops) {
			go:
			while (true) {
				if (edges.b) {
					var edge = edges.a;
					var rest = edges.b;
					var withEdge = _Utils_ap(
						current,
						pointsOf(edge));
					var start = $elm$core$Maybe$withDefault$(
						startOf(edge),
						loopStart);
					if (($author$project$Surface$distance2$(
						endOf(edge),
						start) - $author$project$Surface$tolerance) < 0) {
						var $temp$edges = rest,
							$temp$loopStart = $elm$core$Maybe$Nothing,
							$temp$current = _List_Nil,
							$temp$loops = A2($elm$core$List$cons, withEdge, loops);
						edges = $temp$edges;
						loopStart = $temp$loopStart;
						current = $temp$current;
						loops = $temp$loops;
						continue go;
					} else {
						var $temp$edges = rest,
							$temp$loopStart = $elm$core$Maybe$Just(start),
							$temp$current = withEdge;
						edges = $temp$edges;
						loopStart = $temp$loopStart;
						current = $temp$current;
						continue go;
					}
				} else {
					return $elm$core$List$isEmpty(current) ? $elm$core$List$reverse(loops) : $elm$core$List$reverse(
						A2($elm$core$List$cons, current, loops));
				}
			}
		});
	return A4(
		go,
		$elm$core$Array$toList(flat.bS),
		$elm$core$Maybe$Nothing,
		_List_Nil,
		_List_Nil);
};
var $author$project$Surface$flatLoops = F2($author$project$Surface$flatLoops$);
var $elm$core$List$any$ = function (isOkay, list) {
	any:
	while (true) {
		if (!list.b) {
			return false;
		} else {
			var x = list.a;
			var xs = list.b;
			if (isOkay(x)) {
				return true;
			} else {
				var $temp$list = xs;
				list = $temp$list;
				continue any;
			}
		}
	}
};
var $elm$core$List$any = F2($elm$core$List$any$);
var $elm$core$List$filter$ = function (isGood, list) {
	return $elm$core$List$foldr$(
		F2(
			function (x, xs) {
				return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
			}),
		_List_Nil,
		list);
};
var $elm$core$List$filter = F2($elm$core$List$filter$);
var $elm$core$Tuple$pair$ = function (a, b) {
	return _Utils_Tuple2(a, b);
};
var $elm$core$Tuple$pair = F2($elm$core$Tuple$pair$);
var $elm$core$List$sortBy = _List_sortBy;
var $elm$core$List$takeReverse$ = function (n, list, kept) {
	takeReverse:
	while (true) {
		if (n <= 0) {
			return kept;
		} else {
			if (!list.b) {
				return kept;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$n = n - 1,
					$temp$list = xs,
					$temp$kept = A2($elm$core$List$cons, x, kept);
				n = $temp$n;
				list = $temp$list;
				kept = $temp$kept;
				continue takeReverse;
			}
		}
	}
};
var $elm$core$List$takeReverse = F3($elm$core$List$takeReverse$);
var $elm$core$List$takeTailRec$ = function (n, list) {
	return $elm$core$List$reverse(
		$elm$core$List$takeReverse$(n, list, _List_Nil));
};
var $elm$core$List$takeTailRec = F2($elm$core$List$takeTailRec$);
var $elm$core$List$takeFast$ = function (ctr, n, list) {
	if (n <= 0) {
		return _List_Nil;
	} else {
		var _v0 = _Utils_Tuple2(n, list);
		_v0$1:
		while (true) {
			_v0$5:
			while (true) {
				if (!_v0.b.b) {
					return list;
				} else {
					if (_v0.b.b.b) {
						switch (_v0.a) {
							case 1:
								break _v0$1;
							case 2:
								var _v2 = _v0.b;
								var x = _v2.a;
								var _v3 = _v2.b;
								var y = _v3.a;
								return _List_fromArray(
									[x, y]);
							case 3:
								if (_v0.b.b.b.b) {
									var _v4 = _v0.b;
									var x = _v4.a;
									var _v5 = _v4.b;
									var y = _v5.a;
									var _v6 = _v5.b;
									var z = _v6.a;
									return _List_fromArray(
										[x, y, z]);
								} else {
									break _v0$5;
								}
							default:
								if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
									var _v7 = _v0.b;
									var x = _v7.a;
									var _v8 = _v7.b;
									var y = _v8.a;
									var _v9 = _v8.b;
									var z = _v9.a;
									var _v10 = _v9.b;
									var w = _v10.a;
									var tl = _v10.b;
									return (ctr > 1000) ? A2(
										$elm$core$List$cons,
										x,
										A2(
											$elm$core$List$cons,
											y,
											A2(
												$elm$core$List$cons,
												z,
												A2(
													$elm$core$List$cons,
													w,
													$elm$core$List$takeTailRec$(n - 4, tl))))) : A2(
										$elm$core$List$cons,
										x,
										A2(
											$elm$core$List$cons,
											y,
											A2(
												$elm$core$List$cons,
												z,
												A2(
													$elm$core$List$cons,
													w,
													$elm$core$List$takeFast$(ctr + 1, n - 4, tl)))));
								} else {
									break _v0$5;
								}
						}
					} else {
						if (_v0.a === 1) {
							break _v0$1;
						} else {
							break _v0$5;
						}
					}
				}
			}
			return list;
		}
		var _v1 = _v0.b;
		var x = _v1.a;
		return _List_fromArray(
			[x]);
	}
};
var $elm$core$List$takeFast = F3($elm$core$List$takeFast$);
var $elm$core$List$take$ = function (n, list) {
	return $elm$core$List$takeFast$(0, n, list);
};
var $elm$core$List$take = F2($elm$core$List$take$);
var $author$project$Surface$withHoles$ = function (outer, holes) {
	var rightmost = function (hole) {
		return $elm$core$List$foldl$(
			F2(
				function (p, best) {
					return $author$project$Surface$maxFloat$(best, p.m);
				}),
			(-1) / 0,
			hole);
	};
	var edgesOf = function (loop) {
		return A3(
			$elm$core$List$map2,
			$elm$core$Tuple$pair,
			loop,
			_Utils_ap(
				$elm$core$List$drop$(1, loop),
				$elm$core$List$take$(1, loop)));
	};
	var crosses = F3(
		function (p, q, _v8) {
			var a = _v8.a;
			var b = _v8.b;
			var touches = ($author$project$Surface$distance2$(a, p) < 1.0e-9) || (($author$project$Surface$distance2$(a, q) < 1.0e-9) || (($author$project$Surface$distance2$(b, p) < 1.0e-9) || ($author$project$Surface$distance2$(b, q) < 1.0e-9)));
			return (!touches) && ((($author$project$Surface$turn$(p, q, a) * $author$project$Surface$turn$(p, q, b)) < 0) && (($author$project$Surface$turn$(a, b, p) * $author$project$Surface$turn$(a, b, q)) < 0));
		});
	var addHole = F2(
		function (hole, _v7) {
			var loop = _v7.a;
			var otherHoles = _v7.b;
			var remaining = $elm$core$List$filter$(
				$elm$core$Basics$neq(hole),
				otherHoles);
			var mostRight = $elm$core$List$foldl$(
				F2(
					function (_v5, _v6) {
						var i = _v5.a;
						var p = _v5.b;
						var bestI = _v6.a;
						var bestP = _v6.b;
						return ((p.m - bestP.m) > 0) ? _Utils_Tuple2(i, p) : _Utils_Tuple2(bestI, bestP);
					}),
				_Utils_Tuple2(
					0,
					$elm$core$Maybe$withDefault$(
						{m: 0, n: 0},
						$elm$core$List$head(hole))),
				$elm$core$List$indexedMap$($elm$core$Tuple$pair, hole));
			var blockers = _Utils_ap(
				edgesOf(loop),
				$elm$core$List$concatMap$(
					edgesOf,
					A2($elm$core$List$cons, hole, remaining)));
			var _v0 = mostRight;
			var holeIndex = _v0.a;
			var m = _v0.b;
			var bridge = $elm$core$List$head(
				$elm$core$List$filter$(
					function (_v4) {
						var p = _v4.b;
						return !$elm$core$List$any$(
							A2(crosses, p, m),
							blockers);
					},
					A2(
						$elm$core$List$sortBy,
						function (_v3) {
							var p = _v3.b;
							return $author$project$Surface$distance2$(p, m);
						},
						$elm$core$List$indexedMap$($elm$core$Tuple$pair, loop))));
			if (!bridge.$) {
				var _v2 = bridge.a;
				var loopIndex = _v2.a;
				var p = _v2.b;
				return _Utils_Tuple2(
					_Utils_ap(
						$elm$core$List$take$(loopIndex + 1, loop),
						_Utils_ap(
							$elm$core$List$drop$(holeIndex, hole),
							_Utils_ap(
								$elm$core$List$take$(holeIndex + 1, hole),
								A2(
									$elm$core$List$cons,
									p,
									$elm$core$List$drop$(loopIndex + 1, loop))))),
					remaining);
			} else {
				return _Utils_Tuple2(loop, remaining);
			}
		});
	return function (sorted) {
		return $elm$core$List$foldl$(
			addHole,
			_Utils_Tuple2(outer, sorted),
			sorted);
	}(
		A2(
			$elm$core$List$sortBy,
			function (hole) {
				return -rightmost(hole);
			},
			holes)).a;
};
var $author$project$Surface$withHoles = F2($author$project$Surface$withHoles$);
var $author$project$Surface$tessellateFlat$ = function (maxStepAngle, flat) {
	var vertex = function (p) {
		return {
			k: flat.s,
			gQ: $author$project$Surface$flatPoint$(flat, p.m, p.n)
		};
	};
	var _v0 = $author$project$Surface$flatLoops$(maxStepAngle, flat);
	if (_v0.b) {
		var outer = _v0.a;
		var holes = _v0.b;
		return $elm$core$List$foldl$(
			F2(
				function (_v1, acc) {
					var a = _v1.a;
					var b = _v1.b;
					var c = _v1.c;
					return $author$project$Surface$meshTriangle$(
						vertex(a),
						vertex(b),
						vertex(c),
						acc);
				}),
			_List_Nil,
			$author$project$Surface$earClip(
				$author$project$Surface$withHoles$(outer, holes)));
	} else {
		return _List_Nil;
	}
};
var $author$project$Surface$tessellateFlat = F2($author$project$Surface$tessellateFlat$);
var $author$project$Surface$boxAround = function (piece) {
	var spare = 0.01;
	var corners = $elm$core$List$concatMap$(
		function (_v1) {
			var a = _v1.a;
			var b = _v1.b;
			var c = _v1.c;
			return _List_fromArray(
				[a.gQ, b.gQ, c.gQ]);
		},
		function () {
			if (!piece.$) {
				var flat = piece.a;
				return $author$project$Surface$tessellateFlat$($author$project$Surface$boxStepAngle, flat);
			} else {
				var feature = piece.a;
				return $author$project$Surface$tessellateFeature$($author$project$Surface$boxStepAngle, feature);
			}
		}());
	var bound = F2(
		function (pick, get) {
			return $elm$core$List$foldl$(
				pick,
				get(
					$elm$core$Maybe$withDefault$(
						$author$project$Surface$vec$(0, 0, 0),
						$elm$core$List$head(corners))),
				$elm$core$List$map$(get, corners));
		});
	return {
		a2: $author$project$Surface$vec$(
			A2(
				bound,
				$author$project$Surface$maxFloat,
				function ($) {
					return $.m;
				}) + spare,
			A2(
				bound,
				$author$project$Surface$maxFloat,
				function ($) {
					return $.n;
				}) + spare,
			A2(
				bound,
				$author$project$Surface$maxFloat,
				function ($) {
					return $.o;
				}) + spare),
		a3: $author$project$Surface$vec$(
			A2(
				bound,
				$author$project$Surface$minFloat,
				function ($) {
					return $.m;
				}) - spare,
			A2(
				bound,
				$author$project$Surface$minFloat,
				function ($) {
					return $.n;
				}) - spare,
			A2(
				bound,
				$author$project$Surface$minFloat,
				function ($) {
					return $.o;
				}) - spare)
	};
};
var $author$project$Surface$ArcSeg = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$DegenerateProfile = {$: 3};
var $author$project$Surface$LineSeg = function (a) {
	return {$: 0, a: a};
};
var $ianmackenzie$elm_geometry$Direction3d$unwrap = function (_v0) {
	var coordinates = _v0;
	return coordinates;
};
var $author$project$Surface$fromDirection = function (direction) {
	return $ianmackenzie$elm_geometry$Direction3d$unwrap(direction);
};
var $ianmackenzie$elm_units$Angle$inRadians = function (_v0) {
	var numRadians = _v0;
	return numRadians;
};
var $ianmackenzie$elm_geometry$Frame3d$originPoint = function (_v0) {
	var properties = _v0;
	return properties.gK;
};
var $author$project$Surface$sweepStart = function (feature) {
	var _v0 = feature.jg;
	if (!_v0.$) {
		var from = _v0.a.c;
		return from;
	} else {
		return 0;
	}
};
var $ianmackenzie$elm_geometry$Point2d$toMeters = function (_v0) {
	var coordinates = _v0;
	return coordinates;
};
var $ianmackenzie$elm_geometry$Frame3d$xDirection = function (_v0) {
	var properties = _v0;
	return properties.g6;
};
var $ianmackenzie$elm_geometry$Frame3d$yDirection = function (_v0) {
	var properties = _v0;
	return properties.g7;
};
var $ianmackenzie$elm_geometry$Frame3d$zDirection = function (_v0) {
	var properties = _v0;
	return properties.jO;
};
var $author$project$Surface$buildFeature = function (spec) {
	var start = $ianmackenzie$elm_geometry$Point2d$toMeters(spec.u.fz);
	var ez = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$zDirection(spec.h_));
	var ey = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$yDirection(spec.h_));
	var ex = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$xDirection(spec.h_));
	var _v0 = function (_v3) {
		var acc = _v3.a;
		var total = _v3.b;
		return _Utils_Tuple2(
			$elm$core$List$reverse(acc),
			total);
	}(
		$elm$core$List$foldl$(
			F2(
				function (segment, _v1) {
					var acc = _v1.a;
					var s0 = _v1.b;
					var point = _v1.c;
					if (!segment.$) {
						var end = segment.a.f_;
						var e = $ianmackenzie$elm_geometry$Point2d$toMeters(end);
						var len = $elm$core$Basics$sqrt(
							A2($elm$core$Basics$pow, e.m - point.m, 2) + A2($elm$core$Basics$pow, e.n - point.n, 2));
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								$author$project$Surface$LineSeg(
									{aP: (e.n - point.n) / len, N: (e.m - point.m) / len, cX: point.n, af: len, b2: point.m, ak: s0}),
								acc),
							s0 + len,
							e);
					} else {
						var center = segment.a.b;
						var end = segment.a.f_;
						var e = $ianmackenzie$elm_geometry$Point2d$toMeters(end);
						var c = $ianmackenzie$elm_geometry$Point2d$toMeters(center);
						var radius = $elm$core$Basics$sqrt(
							A2($elm$core$Basics$pow, point.m - c.m, 2) + A2($elm$core$Basics$pow, point.n - c.n, 2));
						var a1 = A2($elm$core$Basics$atan2, e.n - c.n, e.m - c.m);
						var a0 = A2($elm$core$Basics$atan2, point.n - c.n, point.m - c.m);
						var delta = $author$project$Surface$wrapAngle((a1 - a0) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
						var len = $elm$core$Basics$abs(delta) * radius;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								$author$project$Surface$ArcSeg(
									{
										S: a0,
										cg: c.n,
										bM: c.m,
										cj: (delta < 0) ? (-1) : 1,
										af: len,
										p: radius,
										ak: s0
									}),
								acc),
							s0 + len,
							e);
					}
				}),
			_Utils_Tuple3(_List_Nil, 0, start),
			spec.u.gX));
	var segments = _v0.a;
	var length = _v0.b;
	var feature = {
		aN: 1,
		az: ex,
		aA: ey,
		an: ez,
		aR: length,
		z: $author$project$Surface$fromPoint(
			$ianmackenzie$elm_geometry$Frame3d$originPoint(spec.h_)),
		gX: segments,
		jg: function () {
			var _v4 = spec.jg;
			if (!_v4.$) {
				return $elm$core$Maybe$Nothing;
			} else {
				var to = _v4.a.e;
				var from = _v4.a.c;
				return $elm$core$Maybe$Just(
					{
						c: $ianmackenzie$elm_units$Angle$inRadians(from),
						e: $ianmackenzie$elm_units$Angle$inRadians(to)
					});
			}
		}()
	};
	var basis = $author$project$Surface$featureBasis$(
		feature,
		$author$project$Surface$sweepStart(feature),
		length / 2);
	return ($elm$core$List$isEmpty(segments) || $elm$core$List$any$(
		function (segment) {
			return _Utils_cmp(
				$author$project$Surface$segLength(segment),
				$author$project$Surface$tolerance) < 0;
		},
		segments)) ? $elm$core$Result$Err($author$project$Surface$DegenerateProfile) : $elm$core$Result$Ok(
		_Utils_update(
			feature,
			{
				aN: ($author$project$Surface$dot$(
					$author$project$Surface$cross$(basis.s, basis.ax),
					basis.ay) < 0) ? (-1) : 1
			}));
};
var $author$project$Surface$DegenerateFlatEdge = {$: 2};
var $author$project$Surface$ArcEdge = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$SegmentEdge = function (a) {
	return {$: 0, a: a};
};
var $author$project$Surface$buildLoop = function (loop) {
	var startOf = function (edge) {
		if (!edge.$) {
			var start = edge.a;
			return start;
		} else {
			var start = edge.a.fz;
			return start;
		}
	};
	var nextStarts = $elm$core$List$map$(
		startOf,
		_Utils_ap(
			$elm$core$List$drop$(1, loop),
			$elm$core$List$take$(1, loop)));
	return A3(
		$elm$core$List$map2,
		F2(
			function (edge, next) {
				if (!edge.$) {
					var start = edge.a;
					var b = $ianmackenzie$elm_geometry$Point2d$toMeters(next);
					var a = $ianmackenzie$elm_geometry$Point2d$toMeters(start);
					return $author$project$Surface$SegmentEdge(
						{aL: a.m, aM: a.n, aW: b.m, aX: b.n});
				} else {
					var sweptAngle = edge.a.jh;
					var center = edge.a.b;
					var start = edge.a.fz;
					var s = $ianmackenzie$elm_geometry$Point2d$toMeters(start);
					var c = $ianmackenzie$elm_geometry$Point2d$toMeters(center);
					return $author$project$Surface$ArcEdge(
						{
							S: A2($elm$core$Basics$atan2, s.n - c.n, s.m - c.m),
							av: c.m,
							aw: c.n,
							f: $elm$core$Basics$sqrt(
								A2($elm$core$Basics$pow, s.m - c.m, 2) + A2($elm$core$Basics$pow, s.n - c.n, 2)),
							aI: $ianmackenzie$elm_units$Angle$inRadians(sweptAngle)
						});
				}
			}),
		loop,
		nextStarts);
};
var $author$project$Surface$edgeIsDegenerate = function (edge) {
	if (!edge.$) {
		var by = edge.a.aX;
		var bx = edge.a.aW;
		var ay = edge.a.aM;
		var ax = edge.a.aL;
		return _Utils_cmp(
			$elm$core$Basics$sqrt(
				A2($elm$core$Basics$pow, bx - ax, 2) + A2($elm$core$Basics$pow, by - ay, 2)),
			$author$project$Surface$tolerance) < 0;
	} else {
		var swept = edge.a.aI;
		var r = edge.a.f;
		return _Utils_cmp(
			$elm$core$Basics$abs(r * swept),
			$author$project$Surface$tolerance) < 0;
	}
};
var $ianmackenzie$elm_geometry$SketchPlane3d$originPoint = function (_v0) {
	var properties = _v0;
	return properties.gK;
};
var $ianmackenzie$elm_geometry$SketchPlane3d$xDirection = function (_v0) {
	var properties = _v0;
	return properties.g6;
};
var $ianmackenzie$elm_geometry$SketchPlane3d$yDirection = function (_v0) {
	var properties = _v0;
	return properties.g7;
};
var $author$project$Surface$buildFlat = function (spec) {
	var v = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$SketchPlane3d$yDirection(spec.iO));
	var u = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$SketchPlane3d$xDirection(spec.iO));
	var origin = $author$project$Surface$fromPoint(
		$ianmackenzie$elm_geometry$SketchPlane3d$originPoint(spec.iO));
	var edges = $elm$core$List$concatMap$($author$project$Surface$buildLoop, spec.eM);
	return $elm$core$List$any$($author$project$Surface$edgeIsDegenerate, edges) ? $elm$core$Result$Err($author$project$Surface$DegenerateFlatEdge) : $elm$core$Result$Ok(
		{
			bS: $elm$core$Array$fromList(edges),
			s: $author$project$Surface$cross$(u, v),
			z: origin,
			a9: u,
			bb: v
		});
};
var $elm$core$Result$map2$ = function (func, ra, rb) {
	if (ra.$ === 1) {
		var x = ra.a;
		return $elm$core$Result$Err(x);
	} else {
		var a = ra.a;
		if (rb.$ === 1) {
			var x = rb.a;
			return $elm$core$Result$Err(x);
		} else {
			var b = rb.a;
			return $elm$core$Result$Ok(
				A2(func, a, b));
		}
	}
};
var $elm$core$Result$map2 = F3($elm$core$Result$map2$);
var $author$project$Surface$combineResults = function (results) {
	return $elm$core$List$foldr$(
		F2(
			function (result, acc) {
				return $elm$core$Result$map2$($elm$core$List$cons, result, acc);
			}),
		$elm$core$Result$Ok(_List_Nil),
		results);
};
var $author$project$Surface$EdgeSharedBy3OrMorePieces = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$UnmatchedEdge = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$composeL$ = function (g, f, x) {
	return g(
		f(x));
};
var $elm$core$Basics$composeL = F3($elm$core$Basics$composeL$);
var $elm$core$List$all$ = function (isOkay, list) {
	return !$elm$core$List$any$(
		A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
		list);
};
var $elm$core$List$all = F2($elm$core$List$all$);
var $author$project$Surface$combineMaybes = function (maybes) {
	return $elm$core$List$foldr$(
		F2(
			function (maybe, acc) {
				return $elm$core$Maybe$map2$($elm$core$List$cons, maybe, acc);
			}),
		$elm$core$Maybe$Just(_List_Nil),
		maybes);
};
var $author$project$Surface$edgeCount = function (piece) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$Array$length(flat.bS);
	} else {
		var feature = piece.a;
		var _v1 = feature.jg;
		if (!_v1.$) {
			return 4;
		} else {
			return 2;
		}
	}
};
var $author$project$Surface$edgeSample$ = function (piece, edgeIndex, t) {
	if (!piece.$) {
		var flat = piece.a;
		var _v1 = $elm$core$Array$get$(edgeIndex, flat.bS);
		if (!_v1.$) {
			if (!_v1.a.$) {
				var by = _v1.a.a.aX;
				var bx = _v1.a.a.aW;
				var ay = _v1.a.a.aM;
				var ax = _v1.a.a.aL;
				return $elm$core$Maybe$Just(
					$author$project$Surface$flatPoint$(flat, ax + (t * (bx - ax)), ay + (t * (by - ay))));
			} else {
				var swept = _v1.a.a.aI;
				var a0 = _v1.a.a.S;
				var r = _v1.a.a.f;
				var cy = _v1.a.a.aw;
				var cx = _v1.a.a.av;
				var angle = a0 + (t * swept);
				return $elm$core$Maybe$Just(
					$author$project$Surface$flatPoint$(
						flat,
						cx + (r * $elm$core$Basics$cos(angle)),
						cy + (r * $elm$core$Basics$sin(angle))));
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		var feature = piece.a;
		var _v2 = $author$project$Surface$sweepRange(feature);
		var from = _v2.a;
		var to = _v2.b;
		switch (edgeIndex) {
			case 0:
				return (_Utils_cmp(
					$elm$core$Basics$abs(
						$author$project$Surface$profileAt$(feature, 0).f),
					$author$project$Surface$tolerance) < 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, from + (t * (to - from)), 0));
			case 1:
				return (($elm$core$Basics$abs(
					$author$project$Surface$profileAt$(feature, feature.aR).f) - $author$project$Surface$tolerance) < 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, from + (t * (to - from)), feature.aR));
			case 2:
				return $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, from, t * feature.aR));
			case 3:
				return $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, to, t * feature.aR));
			default:
				return $elm$core$Maybe$Nothing;
		}
	}
};
var $author$project$Surface$edgeSample = F3($author$project$Surface$edgeSample$);
var $elm$core$List$maybeCons$ = function (f, mx, xs) {
	var _v0 = f(mx);
	if (!_v0.$) {
		var x = _v0.a;
		return A2($elm$core$List$cons, x, xs);
	} else {
		return xs;
	}
};
var $elm$core$List$maybeCons = F3($elm$core$List$maybeCons$);
var $elm$core$List$filterMap$ = function (f, xs) {
	return $elm$core$List$foldr$(
		$elm$core$List$maybeCons(f),
		_List_Nil,
		xs);
};
var $elm$core$List$filterMap = F2($elm$core$List$filterMap$);
var $author$project$Surface$locateOnEdge$ = function (piece, edgeIndex, point) {
	if (!piece.$) {
		var flat = piece.a;
		var local = $author$project$Surface$sub$(point, flat.z);
		var _v1 = $elm$core$Array$get$(edgeIndex, flat.bS);
		if (!_v1.$) {
			var edge = _v1.a;
			var _v2 = $author$project$Surface$closestOnEdge2d$(
				edge,
				$author$project$Surface$dot$(local, flat.a9),
				$author$project$Surface$dot$(local, flat.bb));
			var a = _v2.a;
			var b = _v2.b;
			return {cK: a, cM: b};
		} else {
			return {cK: 0, cM: 0};
		}
	} else {
		var feature = piece.a;
		var local = $author$project$Surface$sub$(point, feature.z);
		var x = $author$project$Surface$dot$(local, feature.az);
		var y = $author$project$Surface$dot$(local, feature.aA);
		var profileParam = function (theta) {
			return $author$project$Surface$closestOnProfile$(
				feature,
				(x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta)),
				$author$project$Surface$dot$(local, feature.an));
		};
		var _v3 = $author$project$Surface$sweepRange(feature);
		var from = _v3.a;
		var to = _v3.b;
		switch (edgeIndex) {
			case 0:
				return {
					cK: $author$project$Surface$clampTheta$(
						feature,
						A2($elm$core$Basics$atan2, y, x)),
					cM: 0
				};
			case 1:
				return {
					cK: $author$project$Surface$clampTheta$(
						feature,
						A2($elm$core$Basics$atan2, y, x)),
					cM: feature.aR
				};
			case 2:
				return {
					cK: from,
					cM: profileParam(from)
				};
			default:
				return {
					cK: to,
					cM: profileParam(to)
				};
		}
	}
};
var $author$project$Surface$locateOnEdge = F3($author$project$Surface$locateOnEdge$);
var $author$project$Surface$setSeam$ = function (_v0, other, seams) {
	var pieceIndex = _v0.a;
	var edgeIndex = _v0.b;
	var _v1 = $elm$core$Array$get$(pieceIndex, seams);
	if (!_v1.$) {
		var edges = _v1.a;
		return $elm$core$Array$set$(
			pieceIndex,
			$elm$core$Array$set$(
				edgeIndex,
				$elm$core$Maybe$Just(other),
				edges),
			seams);
	} else {
		return seams;
	}
};
var $author$project$Surface$setSeam = F3($author$project$Surface$setSeam$);
var $elm$core$Array$toIndexedList = function (array) {
	var len = array.a;
	var helper = F2(
		function (entry, _v0) {
			var index = _v0.a;
			var list = _v0.b;
			return _Utils_Tuple2(
				index - 1,
				A2(
					$elm$core$List$cons,
					_Utils_Tuple2(index, entry),
					list));
		});
	return $elm$core$Array$foldr$(
		helper,
		_Utils_Tuple2(len - 1, _List_Nil),
		array).b;
};
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return $elm$core$Dict$RBNode_elm_builtin$(
				0,
				rlK,
				rlV,
				$elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					$elm$core$Dict$RBNode_elm_builtin$(0, lK, lV, lLeft, lRight),
					rlL),
				$elm$core$Dict$RBNode_elm_builtin$(1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return $elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					$elm$core$Dict$RBNode_elm_builtin$(0, lK, lV, lLeft, lRight),
					$elm$core$Dict$RBNode_elm_builtin$(0, rK, rV, rLeft, rRight));
			} else {
				return $elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					$elm$core$Dict$RBNode_elm_builtin$(0, lK, lV, lLeft, lRight),
					$elm$core$Dict$RBNode_elm_builtin$(0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return $elm$core$Dict$RBNode_elm_builtin$(
				0,
				lK,
				lV,
				$elm$core$Dict$RBNode_elm_builtin$(1, llK, llV, llLeft, llRight),
				$elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					lRight,
					$elm$core$Dict$RBNode_elm_builtin$(0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return $elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					$elm$core$Dict$RBNode_elm_builtin$(0, lK, lV, lLeft, lRight),
					$elm$core$Dict$RBNode_elm_builtin$(0, rK, rV, rLeft, rRight));
			} else {
				return $elm$core$Dict$RBNode_elm_builtin$(
					1,
					k,
					v,
					$elm$core$Dict$RBNode_elm_builtin$(0, lK, lV, lLeft, lRight),
					$elm$core$Dict$RBNode_elm_builtin$(0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT$ = function (targetKey, dict, color, key, value, left, right) {
	if ((left.$ === -1) && (!left.a)) {
		var _v1 = left.a;
		var lK = left.b;
		var lV = left.c;
		var lLeft = left.d;
		var lRight = left.e;
		return $elm$core$Dict$RBNode_elm_builtin$(
			color,
			lK,
			lV,
			lLeft,
			$elm$core$Dict$RBNode_elm_builtin$(0, key, value, lRight, right));
	} else {
		_v2$2:
		while (true) {
			if ((right.$ === -1) && (right.a === 1)) {
				if (right.d.$ === -1) {
					if (right.d.a === 1) {
						var _v3 = right.a;
						var _v4 = right.d;
						var _v5 = _v4.a;
						return $elm$core$Dict$moveRedRight(dict);
					} else {
						break _v2$2;
					}
				} else {
					var _v6 = right.a;
					var _v7 = right.d;
					return $elm$core$Dict$moveRedRight(dict);
				}
			} else {
				break _v2$2;
			}
		}
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7($elm$core$Dict$removeHelpPrepEQGT$);
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return $elm$core$Dict$RBNode_elm_builtin$(
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return $elm$core$Dict$balance$(
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return $elm$core$Dict$RBNode_elm_builtin$(
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp$ = function (targetKey, dict) {
	if (dict.$ === -2) {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	} else {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var right = dict.e;
		if (_Utils_cmp(targetKey, key) < 0) {
			if ((left.$ === -1) && (left.a === 1)) {
				var _v4 = left.a;
				var lLeft = left.d;
				if ((lLeft.$ === -1) && (!lLeft.a)) {
					var _v6 = lLeft.a;
					return $elm$core$Dict$RBNode_elm_builtin$(
						color,
						key,
						value,
						$elm$core$Dict$removeHelp$(targetKey, left),
						right);
				} else {
					var _v7 = $elm$core$Dict$moveRedLeft(dict);
					if (_v7.$ === -1) {
						var nColor = _v7.a;
						var nKey = _v7.b;
						var nValue = _v7.c;
						var nLeft = _v7.d;
						var nRight = _v7.e;
						return $elm$core$Dict$balance$(
							nColor,
							nKey,
							nValue,
							$elm$core$Dict$removeHelp$(targetKey, nLeft),
							nRight);
					} else {
						return $elm$core$Dict$RBEmpty_elm_builtin;
					}
				}
			} else {
				return $elm$core$Dict$RBNode_elm_builtin$(
					color,
					key,
					value,
					$elm$core$Dict$removeHelp$(targetKey, left),
					right);
			}
		} else {
			return $elm$core$Dict$removeHelpEQGT$(
				targetKey,
				$elm$core$Dict$removeHelpPrepEQGT$(targetKey, dict, color, key, value, left, right));
		}
	}
};
var $elm$core$Dict$removeHelp = F2($elm$core$Dict$removeHelp$);
var $elm$core$Dict$removeHelpEQGT$ = function (targetKey, dict) {
	if (dict.$ === -1) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var right = dict.e;
		if (_Utils_eq(targetKey, key)) {
			var _v1 = $elm$core$Dict$getMin(right);
			if (_v1.$ === -1) {
				var minKey = _v1.b;
				var minValue = _v1.c;
				return $elm$core$Dict$balance$(
					color,
					minKey,
					minValue,
					left,
					$elm$core$Dict$removeMin(right));
			} else {
				return $elm$core$Dict$RBEmpty_elm_builtin;
			}
		} else {
			return $elm$core$Dict$balance$(
				color,
				key,
				value,
				left,
				$elm$core$Dict$removeHelp$(targetKey, right));
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelpEQGT = F2($elm$core$Dict$removeHelpEQGT$);
var $elm$core$Dict$remove$ = function (key, dict) {
	var _v0 = $elm$core$Dict$removeHelp$(key, dict);
	if ((_v0.$ === -1) && (!_v0.a)) {
		var _v1 = _v0.a;
		var k = _v0.b;
		var v = _v0.c;
		var l = _v0.d;
		var r = _v0.e;
		return $elm$core$Dict$RBNode_elm_builtin$(1, k, v, l, r);
	} else {
		var x = _v0;
		return x;
	}
};
var $elm$core$Dict$remove = F2($elm$core$Dict$remove$);
var $elm$core$Dict$update$ = function (targetKey, alter, dictionary) {
	var _v0 = alter(
		$elm$core$Dict$get$(targetKey, dictionary));
	if (!_v0.$) {
		var value = _v0.a;
		return $elm$core$Dict$insert$(targetKey, value, dictionary);
	} else {
		return $elm$core$Dict$remove$(targetKey, dictionary);
	}
};
var $elm$core$Dict$update = F3($elm$core$Dict$update$);
var $author$project$Surface$findSeams$ = function (_v0, pieces) {
	var open = _v0.fi;
	var samples = function (_v17) {
		var pieceIndex = _v17.a;
		var edgeIndex = _v17.b;
		var _v16 = $elm$core$Array$get$(pieceIndex, pieces);
		if (!_v16.$) {
			var piece = _v16.a;
			return $author$project$Surface$combineMaybes(
				$elm$core$List$map$(
					A2($author$project$Surface$edgeSample, piece, edgeIndex),
					_List_fromArray(
						[0, 0.25, 0.5, 0.75, 1])));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	};
	var middleOf = function (points) {
		if (((((points.b && points.b.b) && points.b.b.b) && points.b.b.b.b) && points.b.b.b.b.b) && (!points.b.b.b.b.b.b)) {
			var p0 = points.a;
			var _v12 = points.b;
			var p1 = _v12.a;
			var _v13 = _v12.b;
			var p2 = _v13.a;
			var _v14 = _v13.b;
			var p3 = _v14.a;
			var _v15 = _v14.b;
			var p4 = _v15.a;
			return (_Utils_cmp(
				$author$project$Surface$lengthOf(
					$author$project$Surface$sub$(p0, p4)),
				$author$project$Surface$tolerance) < 0) ? $elm$core$Maybe$Just(
				$author$project$Surface$scale$(
					0.25,
					$author$project$Surface$add$(
						$author$project$Surface$add$(p0, p1),
						$author$project$Surface$add$(p2, p3)))) : $elm$core$Maybe$Just(p2);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	};
	var liesOn = F2(
		function (_v10, points) {
			var pieceIndex = _v10.a;
			var edgeIndex = _v10.b;
			var _v9 = $elm$core$Array$get$(pieceIndex, pieces);
			if (!_v9.$) {
				var piece = _v9.a;
				return $elm$core$List$all$(
					function (point) {
						var located = $author$project$Surface$locateOnEdge$(piece, edgeIndex, point);
						return _Utils_cmp(
							$author$project$Surface$lengthOf(
								$author$project$Surface$sub$(
									$author$project$Surface$piecePoint$(piece, located.cK, located.cM),
									point)),
							$author$project$Surface$tolerance) < 0;
					},
					points);
			} else {
				return false;
			}
		});
	var meet = F2(
		function (first, second) {
			return (!_Utils_eq(first.dV.a, second.dV.a)) && ((_Utils_cmp(
				$author$project$Surface$lengthOf(
					$author$project$Surface$sub$(first.ct, second.ct)),
				10 * $author$project$Surface$tolerance) < 0) && (A2(liesOn, second.dV, first.fn) && A2(liesOn, first.dV, second.fn)));
		});
	var describe = function (_v8) {
		var pieceIndex = _v8.a;
		var edgeIndex = _v8.b;
		return 'edge ' + ($elm$core$String$fromInt(edgeIndex) + (' of piece ' + $elm$core$String$fromInt(pieceIndex)));
	};
	var allEdges = $elm$core$List$concatMap$(
		function (_v7) {
			var index = _v7.a;
			var piece = _v7.b;
			return $elm$core$List$map$(
				$elm$core$Tuple$pair(index),
				$elm$core$List$range$(
					0,
					$author$project$Surface$edgeCount(piece) - 1));
		},
		$elm$core$Array$toIndexedList(pieces));
	var edgeSamples = $elm$core$Array$fromList(
		A2(
			$elm$core$List$sortBy,
			A2(
				$elm$core$Basics$composeR,
				function ($) {
					return $.ct;
				},
				function ($) {
					return $.m;
				}),
			$elm$core$List$filterMap$(
				function (edge) {
					return $elm$core$Maybe$andThen$(
						function (points) {
							return $elm$core$Maybe$map$(
								function (middle) {
									return {dV: edge, ct: middle, fn: points};
								},
								middleOf(points));
						},
						samples(edge));
				},
				allEdges)));
	var pairsWith = F3(
		function (first, index, acc) {
			pairsWith:
			while (true) {
				var _v1 = $elm$core$Array$get$(index, edgeSamples);
				if (!_v1.$) {
					var second = _v1.a;
					if (_Utils_cmp(second.ct.m - first.ct.m, 10 * $author$project$Surface$tolerance) > 0) {
						return acc;
					} else {
						if (A2(meet, first, second)) {
							var $temp$index = index + 1,
								$temp$acc = A2(
								$elm$core$List$cons,
								_Utils_Tuple2(first.dV, second.dV),
								A2(
									$elm$core$List$cons,
									_Utils_Tuple2(second.dV, first.dV),
									acc));
							index = $temp$index;
							acc = $temp$acc;
							continue pairsWith;
						} else {
							var $temp$index = index + 1;
							index = $temp$index;
							continue pairsWith;
						}
					}
				} else {
					return acc;
				}
			}
		});
	var pairsFrom = F2(
		function (index, acc) {
			pairsFrom:
			while (true) {
				var _v2 = $elm$core$Array$get$(index, edgeSamples);
				if (!_v2.$) {
					var first = _v2.a;
					var $temp$index = index + 1,
						$temp$acc = A3(pairsWith, first, index + 1, acc);
					index = $temp$index;
					acc = $temp$acc;
					continue pairsFrom;
				} else {
					return acc;
				}
			}
		});
	var matches = $elm$core$List$foldl$(
		function (_v6) {
			var edge = _v6.a;
			var other = _v6.b;
			return A2(
				$elm$core$Dict$update,
				edge,
				function (others) {
					return $elm$core$Maybe$Just(
						A2(
							$elm$core$List$cons,
							other,
							$elm$core$Maybe$withDefault$(_List_Nil, others)));
				});
		},
		$elm$core$Dict$empty,
		A2(pairsFrom, 0, _List_Nil));
	return $elm$core$Array$foldl$(
		F2(
			function (_v3, result) {
				var edge = _v3.dV;
				if (!result.$) {
					var seams = result.a;
					var _v5 = $elm$core$Maybe$withDefault$(
						_List_Nil,
						$elm$core$Dict$get$(edge, matches));
					if (_v5.b) {
						if (!_v5.b.b) {
							var other = _v5.a;
							return $elm$core$Result$Ok(
								$author$project$Surface$setSeam$(edge, other, seams));
						} else {
							return $elm$core$Result$Err(
								$author$project$Surface$EdgeSharedBy3OrMorePieces(
									describe(edge)));
						}
					} else {
						return open ? result : $elm$core$Result$Err(
							$author$project$Surface$UnmatchedEdge(
								describe(edge)));
					}
				} else {
					return result;
				}
			}),
		$elm$core$Result$Ok(
			$elm$core$Array$map$(
				function (piece) {
					return $elm$core$Array$repeat$(
						$author$project$Surface$edgeCount(piece),
						$elm$core$Maybe$Nothing);
				},
				pieces)),
		edgeSamples);
};
var $author$project$Surface$findSeams = F2($author$project$Surface$findSeams$);
var $elm$core$Result$map$ = function (func, ra) {
	if (!ra.$) {
		var a = ra.a;
		return $elm$core$Result$Ok(
			func(a));
	} else {
		var e = ra.a;
		return $elm$core$Result$Err(e);
	}
};
var $elm$core$Result$map = F2($elm$core$Result$map$);
var $author$project$Surface$buildWith$ = function (options, flatSpecs, featureSpecs) {
	var _v0 = _Utils_Tuple2(
		$author$project$Surface$combineResults(
			$elm$core$List$map$($author$project$Surface$buildFlat, flatSpecs)),
		$author$project$Surface$combineResults(
			$elm$core$List$map$($author$project$Surface$buildFeature, featureSpecs)));
	if (!_v0.a.$) {
		if (!_v0.b.$) {
			var flats = _v0.a.a;
			var features = _v0.b.a;
			var pieces = $elm$core$Array$fromList(
				_Utils_ap(
					$elm$core$List$map$($author$project$Surface$FlatPiece, flats),
					$elm$core$List$map$($author$project$Surface$FeaturePiece, features)));
			return $elm$core$Result$map$(
				function (seams) {
					return {
						dF: $elm$core$Array$map$($author$project$Surface$boxAround, pieces),
						A: pieces,
						a8: seams
					};
				},
				$author$project$Surface$findSeams$(options, pieces));
		} else {
			var error = _v0.b.a;
			return $elm$core$Result$Err(error);
		}
	} else {
		var error = _v0.a.a;
		return $elm$core$Result$Err(error);
	}
};
var $author$project$Surface$buildWith = F3($author$project$Surface$buildWith$);
var $author$project$Surface$build = $author$project$Surface$buildWith(
	{fi: false});
var $author$project$World$X = 0;
var $author$project$World$Y = 1;
var $author$project$World$Z = 2;
var $author$project$Surface$Circle = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$PartTurn = function (a) {
	return {$: 1, a: a};
};
var $ianmackenzie$elm_units$Quantity$Quantity = $elm$core$Basics$identity;
var $ianmackenzie$elm_units$Angle$radians = function (numRadians) {
	return numRadians;
};
var $ianmackenzie$elm_units$Angle$degrees = function (numDegrees) {
	return $ianmackenzie$elm_units$Angle$radians($elm$core$Basics$pi * (numDegrees / 180));
};
var $author$project$World$filletRadius = 0.198579;
var $author$project$World$box = {
	a2: {m: 4.236575, n: 0.598373, o: 1.992144},
	a3: {m: -3.343595, n: -0.401627, o: -2.452917}
};
var $author$project$World$inner$ = function (axis, sign) {
	var get = function (v) {
		switch (axis) {
			case 0:
				return v.m;
			case 1:
				return v.n;
			default:
				return v.o;
		}
	};
	return (sign > 0) ? (get($author$project$World$box.a2) - $author$project$World$filletRadius) : (get($author$project$World$box.a3) + $author$project$World$filletRadius);
};
var $author$project$World$inner = F2($author$project$World$inner$);
var $ianmackenzie$elm_geometry$Geometry$Types$Point2d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Point2d$meters$ = function (x, y) {
	return {m: x, n: y};
};
var $ianmackenzie$elm_geometry$Point2d$meters = F2($ianmackenzie$elm_geometry$Point2d$meters$);
var $ianmackenzie$elm_geometry$Point2d$origin = {m: 0, n: 0};
var $author$project$World$point = function (coordinates) {
	var get = function (axis) {
		return $elm$core$Maybe$withDefault$(
			0,
			$elm$core$Maybe$map$(
				$elm$core$Tuple$second,
				$elm$core$List$head(
					$elm$core$List$filter$(
						function (_v0) {
							var a = _v0.a;
							return _Utils_eq(a, axis);
						},
						coordinates))));
	};
	return $ianmackenzie$elm_geometry$Point3d$meters$(
		get(0),
		get(1),
		get(2));
};
var $author$project$World$unit$ = function (axis, sign) {
	switch (axis) {
		case 0:
			return $ianmackenzie$elm_geometry$Direction3d$unsafe(
				{m: sign, n: 0, o: 0});
		case 1:
			return $ianmackenzie$elm_geometry$Direction3d$unsafe(
				{m: 0, n: sign, o: 0});
		default:
			return $ianmackenzie$elm_geometry$Direction3d$unsafe(
				{m: 0, n: 0, o: sign});
	}
};
var $author$project$World$unit = F2($author$project$World$unit$);
var $ianmackenzie$elm_geometry$Geometry$Types$Frame3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Frame3d$unsafe = function (properties) {
	return properties;
};
var $author$project$World$corner$ = function (signX, signY, signZ) {
	var _v0 = (((signX * signY) * signZ) < 0) ? _Utils_Tuple2(
		$author$project$World$unit$(0, signX),
		$author$project$World$unit$(2, signZ)) : _Utils_Tuple2(
		$author$project$World$unit$(2, signZ),
		$author$project$World$unit$(0, signX));
	var xDirection = _v0.a;
	var yDirection = _v0.b;
	return {
		h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				gK: $author$project$World$point(
					_List_fromArray(
						[
							_Utils_Tuple2(
							0,
							$author$project$World$inner$(0, signX)),
							_Utils_Tuple2(
							1,
							$author$project$World$inner$(1, signY)),
							_Utils_Tuple2(
							2,
							$author$project$World$inner$(2, signZ))
						])),
				g6: xDirection,
				g7: yDirection,
				jO: $author$project$World$unit$(1, signY)
			}),
		u: {
			gX: _List_fromArray(
				[
					$author$project$Surface$Circle(
					{
						b: $ianmackenzie$elm_geometry$Point2d$origin,
						f_: $ianmackenzie$elm_geometry$Point2d$meters$(0, $author$project$World$filletRadius)
					})
				]),
			fz: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$filletRadius, 0)
		},
		jg: $author$project$Surface$PartTurn(
			{
				c: $ianmackenzie$elm_units$Angle$degrees(0),
				e: $ianmackenzie$elm_units$Angle$degrees(90)
			})
	};
};
var $author$project$World$corner = F3($author$project$World$corner$);
var $author$project$Surface$Line = function (a) {
	return {$: 0, a: a};
};
var $author$project$World$otherAxes = function (axis) {
	switch (axis) {
		case 0:
			return _Utils_Tuple2(1, 2);
		case 1:
			return _Utils_Tuple2(2, 0);
		default:
			return _Utils_Tuple2(0, 1);
	}
};
var $author$project$World$edgeFillet$ = function (along, signA, signB) {
	var zSign = signA * signB;
	var _v0 = $author$project$World$otherAxes(along);
	var a = _v0.a;
	var b = _v0.b;
	return {
		h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				gK: $author$project$World$point(
					_List_fromArray(
						[
							_Utils_Tuple2(
							a,
							$author$project$World$inner$(a, signA)),
							_Utils_Tuple2(
							b,
							$author$project$World$inner$(b, signB))
						])),
				g6: $author$project$World$unit$(a, signA),
				g7: $author$project$World$unit$(b, signB),
				jO: $author$project$World$unit$(along, zSign)
			}),
		u: {
			gX: _List_fromArray(
				[
					$author$project$Surface$Line(
					{
						f_: $ianmackenzie$elm_geometry$Point2d$meters$(
							$author$project$World$filletRadius,
							zSign * $author$project$World$inner$(along, zSign))
					})
				]),
			fz: $ianmackenzie$elm_geometry$Point2d$meters$(
				$author$project$World$filletRadius,
				zSign * $author$project$World$inner$(along, -zSign))
		},
		jg: $author$project$Surface$PartTurn(
			{
				c: $ianmackenzie$elm_units$Angle$degrees(0),
				e: $ianmackenzie$elm_units$Angle$degrees(90)
			})
	};
};
var $author$project$World$edgeFillet = F3($author$project$World$edgeFillet$);
var $author$project$Surface$FullTurn = {$: 0};
var $author$project$World$hill = {aC: 0.15, p: 0.45, m: 3.5, o: -1.3};
var $author$project$World$hillCurveRadius = (A2($elm$core$Basics$pow, $author$project$World$hill.p, 2) + A2($elm$core$Basics$pow, $author$project$World$hill.aC, 2)) / (4 * $author$project$World$hill.aC);
var $ianmackenzie$elm_geometry$Direction3d$negativeZ = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{m: 0, n: 0, o: -1});
var $ianmackenzie$elm_geometry$Direction3d$positiveX = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{m: 1, n: 0, o: 0});
var $ianmackenzie$elm_geometry$Direction3d$x = $ianmackenzie$elm_geometry$Direction3d$positiveX;
var $ianmackenzie$elm_geometry$Direction3d$positiveY = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{m: 0, n: 1, o: 0});
var $ianmackenzie$elm_geometry$Direction3d$y = $ianmackenzie$elm_geometry$Direction3d$positiveY;
var $author$project$World$hillFeature = function () {
	var top = $author$project$World$box.a2.n;
	var r = $author$project$World$hillCurveRadius;
	var peak = {bz: (top + $author$project$World$hill.aC) - r, f: 0};
	var foot = {bz: top + r, f: $author$project$World$hill.p};
	var meet = {bz: foot.bz + ((peak.bz - foot.bz) / 2), f: foot.f + ((peak.f - foot.f) / 2)};
	return {
		h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				gK: $ianmackenzie$elm_geometry$Point3d$meters$($author$project$World$hill.m, 0, $author$project$World$hill.o),
				g6: $ianmackenzie$elm_geometry$Direction3d$x,
				g7: $ianmackenzie$elm_geometry$Direction3d$negativeZ,
				jO: $ianmackenzie$elm_geometry$Direction3d$y
			}),
		u: {
			gX: _List_fromArray(
				[
					$author$project$Surface$Circle(
					{
						b: $ianmackenzie$elm_geometry$Point2d$meters$(foot.f, foot.bz),
						f_: $ianmackenzie$elm_geometry$Point2d$meters$(meet.f, meet.bz)
					}),
					$author$project$Surface$Circle(
					{
						b: $ianmackenzie$elm_geometry$Point2d$meters$(peak.f, peak.bz),
						f_: $ianmackenzie$elm_geometry$Point2d$meters$(0, top + $author$project$World$hill.aC)
					})
				]),
			fz: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hill.p, top)
		},
		jg: $author$project$Surface$FullTurn
	};
}();
var $author$project$World$hole = {cl: 0.30432, eB: 0.47524, m: 1.156, o: -0.2058};
var $author$project$World$holeRim = $author$project$World$hole.eB + $author$project$World$hole.cl;
var $author$project$World$holeFeature = function () {
	var top = $author$project$World$box.a2.n;
	var bottom = $author$project$World$box.a3.n;
	return {
		h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				gK: $ianmackenzie$elm_geometry$Point3d$meters$($author$project$World$hole.m, 0, $author$project$World$hole.o),
				g6: $ianmackenzie$elm_geometry$Direction3d$x,
				g7: $ianmackenzie$elm_geometry$Direction3d$negativeZ,
				jO: $ianmackenzie$elm_geometry$Direction3d$y
			}),
		u: {
			gX: _List_fromArray(
				[
					$author$project$Surface$Circle(
					{
						b: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, top - $author$project$World$hole.cl),
						f_: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.eB, top - $author$project$World$hole.cl)
					}),
					$author$project$Surface$Line(
					{
						f_: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.eB, bottom + $author$project$World$hole.cl)
					}),
					$author$project$Surface$Circle(
					{
						b: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, bottom + $author$project$World$hole.cl),
						f_: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, bottom)
					})
				]),
			fz: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, top)
		},
		jg: $author$project$Surface$FullTurn
	};
}();
var $author$project$World$signs = _List_fromArray(
	[-1, 1]);
var $author$project$World$features = A2(
	$elm$core$List$cons,
	$author$project$World$holeFeature,
	A2(
		$elm$core$List$cons,
		$author$project$World$hillFeature,
		_Utils_ap(
			$elm$core$List$concatMap$(
				function (along) {
					return $elm$core$List$concatMap$(
						function (signA) {
							return $elm$core$List$map$(
								A2($author$project$World$edgeFillet, along, signA),
								$author$project$World$signs);
						},
						$author$project$World$signs);
				},
				_List_fromArray(
					[0, 1, 2])),
			$elm$core$List$concatMap$(
				function (signX) {
					return $elm$core$List$concatMap$(
						function (signY) {
							return $elm$core$List$map$(
								A2($author$project$World$corner, signX, signY),
								$author$project$World$signs);
						},
						$author$project$World$signs);
				},
				$author$project$World$signs))));
var $author$project$Surface$Arc = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$Straight = function (a) {
	return {$: 0, a: a};
};
var $ianmackenzie$elm_geometry$Geometry$Types$Vector2d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Vector2d$meters$ = function (x, y) {
	return {m: x, n: y};
};
var $ianmackenzie$elm_geometry$Vector2d$meters = F2($ianmackenzie$elm_geometry$Vector2d$meters$);
var $author$project$World$outer$ = function (axis, sign) {
	return $author$project$World$inner$(axis, sign) + (sign * $author$project$World$filletRadius);
};
var $author$project$World$outer = F2($author$project$World$outer$);
var $ianmackenzie$elm_geometry$Point2d$translateBy$ = function (_v0, _v1) {
	var v = _v0;
	var p = _v1;
	return {m: p.m + v.m, n: p.n + v.n};
};
var $ianmackenzie$elm_geometry$Point2d$translateBy = F2($ianmackenzie$elm_geometry$Point2d$translateBy$);
var $ianmackenzie$elm_geometry$Geometry$Types$SketchPlane3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$SketchPlane3d$unsafe = $elm$core$Basics$identity;
var $author$project$World$boxFace$ = function (axis, sign) {
	var circle = F3(
		function (x, z, radius) {
			var center = (sign > 0) ? $ianmackenzie$elm_geometry$Point2d$meters$(z, x) : $ianmackenzie$elm_geometry$Point2d$meters$(x, z);
			return _List_fromArray(
				[
					$author$project$Surface$Arc(
					{
						b: center,
						fz: $ianmackenzie$elm_geometry$Point2d$translateBy$(
							$ianmackenzie$elm_geometry$Vector2d$meters$(radius, 0),
							center),
						jh: $ianmackenzie$elm_units$Angle$degrees(-360)
					})
				]);
		});
	var holeLoops = (axis === 1) ? A2(
		$elm$core$List$cons,
		A3(circle, $author$project$World$hole.m, $author$project$World$hole.o, $author$project$World$holeRim),
		(sign > 0) ? _List_fromArray(
			[
				A3(circle, $author$project$World$hill.m, $author$project$World$hill.o, $author$project$World$hill.p)
			]) : _List_Nil) : _List_Nil;
	var _v0 = (sign > 0) ? $author$project$World$otherAxes(axis) : function (_v1) {
		var first = _v1.a;
		var second = _v1.b;
		return _Utils_Tuple2(second, first);
	}(
		$author$project$World$otherAxes(axis));
	var a = _v0.a;
	var b = _v0.b;
	var rectangle = $elm$core$List$map$(
		function (_v2) {
			var sa = _v2.a;
			var sb = _v2.b;
			return $author$project$Surface$Straight(
				$ianmackenzie$elm_geometry$Point2d$meters$(
					$author$project$World$inner$(a, sa),
					$author$project$World$inner$(b, sb)));
		},
		_List_fromArray(
			[
				_Utils_Tuple2(-1, -1),
				_Utils_Tuple2(1, -1),
				_Utils_Tuple2(1, 1),
				_Utils_Tuple2(-1, 1)
			]));
	return {
		eM: A2($elm$core$List$cons, rectangle, holeLoops),
		iO: $ianmackenzie$elm_geometry$SketchPlane3d$unsafe(
			{
				gK: $author$project$World$point(
					_List_fromArray(
						[
							_Utils_Tuple2(
							axis,
							$author$project$World$outer$(axis, sign))
						])),
				g6: $author$project$World$unit$(a, 1),
				g7: $author$project$World$unit$(b, 1)
			})
	};
};
var $author$project$World$boxFace = F2($author$project$World$boxFace$);
var $author$project$World$flats = $elm$core$List$concatMap$(
	function (axis) {
		return $elm$core$List$map$(
			$author$project$World$boxFace(axis),
			$author$project$World$signs);
	},
	_List_fromArray(
		[0, 1, 2]));
var $author$project$World$surface = A2($author$project$Surface$build, $author$project$World$flats, $author$project$World$features);
var $author$project$MeshData$surface = $author$project$World$surface;
var $author$project$WorldShapes$walls = _List_fromArray(
	[
		_List_fromArray(
		[
			_Utils_Tuple3(0.516, 0.598, -0.752),
			_Utils_Tuple3(0.481, 0.598, -0.757),
			_Utils_Tuple3(0.456, 0.598, -0.787),
			_Utils_Tuple3(0.456, 0.598, -0.792),
			_Utils_Tuple3(0.481, 0.598, -0.912),
			_Utils_Tuple3(0.466, 0.598, -1.132),
			_Utils_Tuple3(0.466, 0.598, -1.137),
			_Utils_Tuple3(0.611, 0.598, -1.142),
			_Utils_Tuple3(0.646, 0.598, -1.157),
			_Utils_Tuple3(0.781, 0.598, -1.157),
			_Utils_Tuple3(0.831, 0.598, -1.167),
			_Utils_Tuple3(1.066, 0.598, -1.167),
			_Utils_Tuple3(1.086, 0.598, -1.152),
			_Utils_Tuple3(1.086, 0.598, -1.142),
			_Utils_Tuple3(1.086, 0.598, -1.132),
			_Utils_Tuple3(1.081, 0.598, -1.057),
			_Utils_Tuple3(1.087, 0.598, -0.982)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(-3.124, 0.485, 1.973),
			_Utils_Tuple3(-3.129, 0.471, 1.979),
			_Utils_Tuple3(-3.104, 0.432, 1.989),
			_Utils_Tuple3(-3.069, 0.427, 1.99),
			_Utils_Tuple3(-3.044, 0.408, 1.992),
			_Utils_Tuple3(-3.029, 0.413, 1.992)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(2.381, 0.598, -1.727),
			_Utils_Tuple3(2.376, 0.598, -1.697),
			_Utils_Tuple3(2.376, 0.598, -1.692),
			_Utils_Tuple3(2.546, 0.598, -1.687),
			_Utils_Tuple3(2.661, 0.598, -1.697),
			_Utils_Tuple3(2.721, 0.598, -1.692),
			_Utils_Tuple3(2.736, 0.598, -1.677),
			_Utils_Tuple3(2.741, 0.598, -1.402),
			_Utils_Tuple3(2.731, 0.598, -1.377),
			_Utils_Tuple3(2.731, 0.598, -1.282),
			_Utils_Tuple3(2.721, 0.598, -1.267),
			_Utils_Tuple3(2.721, 0.598, -1.092),
			_Utils_Tuple3(2.721, 0.598, -1.082),
			_Utils_Tuple3(2.721, 0.598, -0.987),
			_Utils_Tuple3(2.696, 0.598, -0.957),
			_Utils_Tuple3(2.131, 0.598, -0.952),
			_Utils_Tuple3(2.011, 0.598, -0.962),
			_Utils_Tuple3(1.996, 0.598, -0.977),
			_Utils_Tuple3(1.996, 0.598, -1.182),
			_Utils_Tuple3(1.996, 0.598, -1.187),
			_Utils_Tuple3(1.986, 0.598, -1.242),
			_Utils_Tuple3(1.991, 0.598, -1.437),
			_Utils_Tuple3(1.991, 0.598, -1.452),
			_Utils_Tuple3(1.961, 0.598, -1.457)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.086, 0.598, -0.682),
			_Utils_Tuple3(-0.014, 0.598, -0.677),
			_Utils_Tuple3(-0.019, 0.598, -0.682),
			_Utils_Tuple3(-0.019, 0.598, -1.082),
			_Utils_Tuple3(-0.019, 0.598, -1.087),
			_Utils_Tuple3(-0.009, 0.598, -1.097),
			_Utils_Tuple3(0.076, 0.598, -1.107),
			_Utils_Tuple3(0.091, 0.598, -1.117),
			_Utils_Tuple3(0.216, 0.598, -1.117),
			_Utils_Tuple3(0.231, 0.598, -1.127),
			_Utils_Tuple3(0.461, 0.598, -1.137)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(3.461, 0.494, 1.969),
			_Utils_Tuple3(3.496, 0.498, 1.966)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.021, -0.402, -0.973),
			_Utils_Tuple3(0.996, -0.402, -1.063),
			_Utils_Tuple3(0.966, -0.402, -1.093),
			_Utils_Tuple3(0.391, -0.402, -1.093),
			_Utils_Tuple3(0.351, -0.402, -1.088),
			_Utils_Tuple3(0.341, -0.402, -1.078),
			_Utils_Tuple3(0.171, -0.402, -1.078),
			_Utils_Tuple3(0.161, -0.402, -1.063),
			_Utils_Tuple3(0.141, -0.402, -1.058),
			_Utils_Tuple3(0.126, -0.402, -1.073),
			_Utils_Tuple3(0.101, -0.402, -1.073)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(3.621, 0.494, 1.969),
			_Utils_Tuple3(3.616, 0.447, 1.986),
			_Utils_Tuple3(3.556, 0.447, 1.986)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.451, 0.598, -0.787),
			_Utils_Tuple3(0.431, 0.598, -0.782),
			_Utils_Tuple3(0.416, 0.598, -0.762),
			_Utils_Tuple3(0.411, 0.598, -0.757),
			_Utils_Tuple3(0.341, 0.598, -0.712),
			_Utils_Tuple3(0.306, 0.598, -0.707)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(3.511, 0.437, 1.989),
			_Utils_Tuple3(3.461, 0.432, 1.989)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.612, -0.292, -0.171),
			_Utils_Tuple3(0.559, -0.341, -0.181),
			_Utils_Tuple3(0.549, -0.349, -0.174),
			_Utils_Tuple3(0.496, -0.377, -0.171),
			_Utils_Tuple3(0.483, -0.383, -0.17),
			_Utils_Tuple3(0.387, -0.401, -0.173),
			_Utils_Tuple3(0.377, -0.402, -0.172),
			_Utils_Tuple3(0.378, -0.402, -0.158),
			_Utils_Tuple3(0.366, -0.402, -0.158),
			_Utils_Tuple3(0.331, -0.402, -0.133),
			_Utils_Tuple3(0.286, -0.402, -0.138),
			_Utils_Tuple3(0.266, -0.402, -0.138),
			_Utils_Tuple3(0.191, -0.402, -0.143),
			_Utils_Tuple3(0.176, -0.402, -0.158),
			_Utils_Tuple3(0.166, -0.402, -0.348),
			_Utils_Tuple3(0.156, -0.402, -0.363),
			_Utils_Tuple3(0.151, -0.402, -0.643),
			_Utils_Tuple3(0.141, -0.402, -0.653),
			_Utils_Tuple3(0.136, -0.402, -0.728),
			_Utils_Tuple3(0.131, -0.402, -1.043),
			_Utils_Tuple3(0.141, -0.402, -1.053),
			_Utils_Tuple3(0.161, -0.402, -1.053),
			_Utils_Tuple3(0.221, -0.402, -0.983),
			_Utils_Tuple3(0.241, -0.402, -0.983),
			_Utils_Tuple3(0.311, -0.402, -0.908),
			_Utils_Tuple3(0.331, -0.402, -0.908),
			_Utils_Tuple3(0.436, -0.402, -0.808),
			_Utils_Tuple3(0.471, -0.402, -0.793),
			_Utils_Tuple3(0.516, -0.402, -0.753),
			_Utils_Tuple3(0.541, -0.402, -0.748),
			_Utils_Tuple3(0.556, -0.402, -0.728),
			_Utils_Tuple3(0.571, -0.402, -0.728),
			_Utils_Tuple3(0.575, -0.401, -0.711),
			_Utils_Tuple3(0.652, -0.383, -0.653),
			_Utils_Tuple3(0.685, -0.356, -0.607),
			_Utils_Tuple3(0.693, -0.352, -0.608),
			_Utils_Tuple3(0.774, -0.345, -0.672),
			_Utils_Tuple3(0.801, -0.33, -0.668)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(-0.019, 0.598, -0.672),
			_Utils_Tuple3(-0.029, 0.598, -0.557),
			_Utils_Tuple3(-0.029, 0.598, -0.312),
			_Utils_Tuple3(-0.019, 0.598, -0.237),
			_Utils_Tuple3(0.001, 0.598, -0.227),
			_Utils_Tuple3(0.141, 0.598, -0.222),
			_Utils_Tuple3(0.166, 0.598, -0.207),
			_Utils_Tuple3(0.376, 0.598, -0.212),
			_Utils_Tuple3(0.376, 0.598, -0.204),
			_Utils_Tuple3(0.639, 0.448, -0.195),
			_Utils_Tuple3(0.644, 0.439, -0.195),
			_Utils_Tuple3(0.681, 0.271, -0.186),
			_Utils_Tuple3(0.682, 0.256, -0.176),
			_Utils_Tuple3(0.682, -0.009, -0.176),
			_Utils_Tuple3(0.682, -0.014, -0.176),
			_Utils_Tuple3(0.682, -0.079, -0.171),
			_Utils_Tuple3(0.681, -0.114, -0.186),
			_Utils_Tuple3(0.635, -0.26, -0.173)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(2.371, 0.598, -1.692),
			_Utils_Tuple3(2.046, 0.598, -1.697),
			_Utils_Tuple3(2.036, 0.598, -1.707),
			_Utils_Tuple3(1.986, 0.598, -1.707)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(-3.104, 0.453, -2.446),
			_Utils_Tuple3(-3.059, 0.448, -2.447)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(3.731, 0.494, 1.969),
			_Utils_Tuple3(3.731, 0.447, 1.986)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.126, 0.598, -1.137),
			_Utils_Tuple3(1.091, 0.598, -1.137)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.069, -0.383, -0.874),
			_Utils_Tuple3(1.051, -0.375, -0.851),
			_Utils_Tuple3(1.049, -0.337, -0.789),
			_Utils_Tuple3(1.043, -0.334, -0.783),
			_Utils_Tuple3(0.948, -0.334, -0.756)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.708, 0.542, -0.45),
			_Utils_Tuple3(1.686, 0.542, -0.496),
			_Utils_Tuple3(1.679, 0.542, -0.507),
			_Utils_Tuple3(1.656, 0.542, -0.545),
			_Utils_Tuple3(1.648, 0.539, -0.547),
			_Utils_Tuple3(1.599, 0.485, -0.52)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.631, 0.296, -0.199),
			_Utils_Tuple3(1.635, 0.361, -0.265),
			_Utils_Tuple3(1.639, 0.366, -0.183),
			_Utils_Tuple3(1.64, 0.371, -0.178),
			_Utils_Tuple3(1.681, 0.462, -0.182),
			_Utils_Tuple3(1.697, 0.485, -0.164),
			_Utils_Tuple3(1.711, 0.507, -0.121),
			_Utils_Tuple3(1.715, 0.511, -0.115),
			_Utils_Tuple3(1.792, 0.566, -0.109),
			_Utils_Tuple3(1.842, 0.584, -0.152),
			_Utils_Tuple3(1.836, 0.584, -0.311),
			_Utils_Tuple3(1.835, 0.588, -0.386),
			_Utils_Tuple3(1.683, 0.588, -0.67),
			_Utils_Tuple3(1.648, 0.584, -0.687),
			_Utils_Tuple3(1.558, 0.519, -0.616),
			_Utils_Tuple3(1.52, 0.425, -0.555),
			_Utils_Tuple3(1.633, 0.425, -0.371),
			_Utils_Tuple3(1.63, 0.361, -0.295),
			_Utils_Tuple3(1.628, 0.351, -0.294),
			_Utils_Tuple3(1.622, 0.301, -0.298)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.974, 0.444, -0.687),
			_Utils_Tuple3(1.09, 0.444, -0.716),
			_Utils_Tuple3(1.095, 0.448, -0.719),
			_Utils_Tuple3(1.1, 0.566, -0.846)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.773, 0.448, -0.553),
			_Utils_Tuple3(0.748, 0.448, -0.524),
			_Utils_Tuple3(0.742, 0.448, -0.515),
			_Utils_Tuple3(0.709, 0.448, -0.466),
			_Utils_Tuple3(0.708, 0.439, -0.453),
			_Utils_Tuple3(0.676, 0.439, -0.385)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.61, 0.326, -0.061),
			_Utils_Tuple3(1.633, 0.376, -0.112),
			_Utils_Tuple3(1.636, 0.386, -0.112),
			_Utils_Tuple3(1.637, 0.396, -0.101),
			_Utils_Tuple3(1.656, 0.439, -0.097),
			_Utils_Tuple3(1.658, 0.444, -0.091),
			_Utils_Tuple3(1.659, 0.462, -0.051)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.708, 0.439, -0.453),
			_Utils_Tuple3(0.728, 0.401, -0.454),
			_Utils_Tuple3(0.743, 0.331, -0.446),
			_Utils_Tuple3(0.74, 0.086, -0.436),
			_Utils_Tuple3(0.74, 0.076, -0.436),
			_Utils_Tuple3(0.742, 0.026, -0.44),
			_Utils_Tuple3(0.74, 0.021, -0.436),
			_Utils_Tuple3(0.704, 0.021, -0.353),
			_Utils_Tuple3(0.69, 0.001, -0.3),
			_Utils_Tuple3(0.681, -0.009, -0.181)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.942, 0.001, -0.63),
			_Utils_Tuple3(1.012, 0.006, -0.659),
			_Utils_Tuple3(1.036, 0.021, -0.666),
			_Utils_Tuple3(1.085, 0.021, -0.676),
			_Utils_Tuple3(1.09, 0.016, -0.676),
			_Utils_Tuple3(1.085, -0.237, -0.71),
			_Utils_Tuple3(1.079, -0.246, -0.714),
			_Utils_Tuple3(1.068, -0.296, -0.748),
			_Utils_Tuple3(1.067, -0.305, -0.756),
			_Utils_Tuple3(1.05, -0.33, -0.779)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.792, 0.566, -0.109),
			_Utils_Tuple3(1.807, 0.575, -0.085),
			_Utils_Tuple3(1.868, 0.593, -0.074),
			_Utils_Tuple3(1.874, 0.595, -0.065),
			_Utils_Tuple3(1.855, 0.593, -0.015)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.627, 0.231, -0.139),
			_Utils_Tuple3(1.624, 0.256, -0.124),
			_Utils_Tuple3(1.625, 0.331, -0.114),
			_Utils_Tuple3(1.635, 0.366, -0.138),
			_Utils_Tuple3(1.639, 0.366, -0.173)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.09, 0.026, -0.676),
			_Utils_Tuple3(1.095, 0.116, -0.677)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.634, 0.577, -0.622),
			_Utils_Tuple3(0.743, 0.453, -0.521)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.099, 0.336, -0.681),
			_Utils_Tuple3(1.095, 0.439, -0.714)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.791, 0.011, -0.51),
			_Utils_Tuple3(0.745, 0.021, -0.444)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.626, -0.337, -0.47),
			_Utils_Tuple3(0.62, -0.345, -0.481),
			_Utils_Tuple3(0.639, -0.352, -0.536),
			_Utils_Tuple3(0.685, -0.352, -0.598)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.678, 0.539, -0.499),
			_Utils_Tuple3(1.653, 0.515, -0.485),
			_Utils_Tuple3(1.653, 0.511, -0.478),
			_Utils_Tuple3(1.671, 0.511, -0.44)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.628, 0.356, -0.3),
			_Utils_Tuple3(1.621, 0.341, -0.319),
			_Utils_Tuple3(1.597, 0.336, -0.39),
			_Utils_Tuple3(1.58, 0.351, -0.432),
			_Utils_Tuple3(1.526, 0.346, -0.511),
			_Utils_Tuple3(1.519, 0.346, -0.519),
			_Utils_Tuple3(1.498, 0.366, -0.548),
			_Utils_Tuple3(1.492, 0.405, -0.571)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(0.551, -0.352, -0.308),
			_Utils_Tuple3(0.556, -0.345, -0.263),
			_Utils_Tuple3(0.554, -0.345, -0.187)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.747, 0.535, -0.26),
			_Utils_Tuple3(1.738, 0.531, -0.296),
			_Utils_Tuple3(1.744, 0.539, -0.316),
			_Utils_Tuple3(1.724, 0.539, -0.395),
			_Utils_Tuple3(1.697, 0.519, -0.399),
			_Utils_Tuple3(1.702, 0.511, -0.357),
			_Utils_Tuple3(1.683, 0.489, -0.351),
			_Utils_Tuple3(1.663, 0.485, -0.399),
			_Utils_Tuple3(1.651, 0.481, -0.419),
			_Utils_Tuple3(1.629, 0.481, -0.465),
			_Utils_Tuple3(1.646, 0.507, -0.481)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.711, 0.507, -0.115),
			_Utils_Tuple3(1.695, 0.494, -0.094),
			_Utils_Tuple3(1.659, 0.444, -0.096)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.883, 0.596, -0.071),
			_Utils_Tuple3(1.919, 0.598, -0.089),
			_Utils_Tuple3(1.929, 0.598, -0.104)
		]),
		_List_fromArray(
		[
			_Utils_Tuple3(1.688, 0.481, -0.294),
			_Utils_Tuple3(1.738, 0.531, -0.296)
		])
	]);
var $author$project$MeshData$mapShapes = function () {
	var _v0 = $author$project$MeshData$surface;
	if (!_v0.$) {
		var surface_ = _v0.a;
		return $author$project$Shapes$prepare$(surface_, $author$project$WorldShapes$walls, $author$project$WorldShapes$pavings);
	} else {
		return $author$project$Shapes$empty;
	}
}();
var $elm$core$Result$toMaybe = function (result) {
	if (!result.$) {
		var v = result.a;
		return $elm$core$Maybe$Just(v);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$MinimapWorker$init = {
	bF: {cz: $author$project$WorldShapes$pavings, jE: $author$project$WorldShapes$walls},
	bG: $author$project$MeshData$mapShapes,
	b4: $elm$core$Result$toMaybe($author$project$MeshData$surface)
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $author$project$GridLevel$Arc = function (a) {
	return {$: 1, a: a};
};
var $author$project$GridLevel$FlatCell = function (a) {
	return {$: 0, a: a};
};
var $author$project$GridLevel$ProfileArc = function (a) {
	return {$: 1, a: a};
};
var $author$project$GridLevel$ProfileLine$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $author$project$GridLevel$ProfileLine = F2($author$project$GridLevel$ProfileLine$);
var $author$project$GridLevel$RoundCell = function (a) {
	return {$: 1, a: a};
};
var $author$project$GridLevel$Segment$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $author$project$GridLevel$Segment = F2($author$project$GridLevel$Segment$);
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $author$project$GridLevel$ivec$ = function (x, y, z) {
	return {m: x, n: y, o: z};
};
var $author$project$GridLevel$ivec = F3($author$project$GridLevel$ivec$);
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $author$project$GridLevel$decoder = function () {
	var toIVec = function (list) {
		if (((list.b && list.b.b) && list.b.b.b) && (!list.b.b.b.b)) {
			var x = list.a;
			var _v25 = list.b;
			var y = _v25.a;
			var _v26 = _v25.b;
			var z = _v26.a;
			return $elm$json$Json$Decode$succeed(
				$author$project$GridLevel$ivec$(x, y, z));
		} else {
			return $elm$json$Json$Decode$fail('Expected 3 numbers');
		}
	};
	var profile = A2(
		$elm$json$Json$Decode$andThen,
		function (list) {
			_v15$2:
			while (true) {
				if (((list.b && list.b.b) && list.b.b.b) && list.b.b.b.b) {
					if (!list.b.b.b.b.b) {
						var a = list.a;
						var _v16 = list.b;
						var b = _v16.a;
						var _v17 = _v16.b;
						var c = _v17.a;
						var _v18 = _v17.b;
						var d = _v18.a;
						return $elm$json$Json$Decode$succeed(
							$author$project$GridLevel$ProfileLine$(
								_Utils_Tuple2(a, b),
								_Utils_Tuple2(c, d)));
					} else {
						if (list.b.b.b.b.b.b && (!list.b.b.b.b.b.b.b)) {
							var a = list.a;
							var _v19 = list.b;
							var b = _v19.a;
							var _v20 = _v19.b;
							var c = _v20.a;
							var _v21 = _v20.b;
							var d = _v21.a;
							var _v22 = _v21.b;
							var e = _v22.a;
							var _v23 = _v22.b;
							var f = _v23.a;
							return $elm$json$Json$Decode$succeed(
								$author$project$GridLevel$ProfileArc(
									{
										b: _Utils_Tuple2(e, f),
										c: _Utils_Tuple2(a, b),
										e: _Utils_Tuple2(c, d)
									}));
						} else {
							break _v15$2;
						}
					}
				} else {
					break _v15$2;
				}
			}
			return $elm$json$Json$Decode$fail('Not a profile');
		},
		$elm$json$Json$Decode$list($elm$json$Json$Decode$int));
	var ivecDecoder = A2(
		$elm$json$Json$Decode$andThen,
		toIVec,
		$elm$json$Json$Decode$list($elm$json$Json$Decode$int));
	var curve = A2(
		$elm$json$Json$Decode$andThen,
		function (list) {
			_v0$2:
			while (true) {
				if (((((list.b && list.b.b) && list.b.b.b) && list.b.b.b.b) && list.b.b.b.b.b) && list.b.b.b.b.b.b) {
					if (!list.b.b.b.b.b.b.b) {
						var ax = list.a;
						var _v1 = list.b;
						var ay = _v1.a;
						var _v2 = _v1.b;
						var az = _v2.a;
						var _v3 = _v2.b;
						var bx = _v3.a;
						var _v4 = _v3.b;
						var by = _v4.a;
						var _v5 = _v4.b;
						var bz = _v5.a;
						return $elm$json$Json$Decode$succeed(
							$author$project$GridLevel$Segment$(
								$author$project$GridLevel$ivec$(ax, ay, az),
								$author$project$GridLevel$ivec$(bx, by, bz)));
					} else {
						if (((list.b.b.b.b.b.b.b.b && list.b.b.b.b.b.b.b.b.b) && list.b.b.b.b.b.b.b.b.b.b) && (!list.b.b.b.b.b.b.b.b.b.b.b)) {
							var cx = list.a;
							var _v6 = list.b;
							var cy = _v6.a;
							var _v7 = _v6.b;
							var cz = _v7.a;
							var _v8 = _v7.b;
							var r = _v8.a;
							var _v9 = _v8.b;
							var fx = _v9.a;
							var _v10 = _v9.b;
							var fy = _v10.a;
							var _v11 = _v10.b;
							var fz = _v11.a;
							var _v12 = _v11.b;
							var tx = _v12.a;
							var _v13 = _v12.b;
							var ty = _v13.a;
							var _v14 = _v13.b;
							var tz = _v14.a;
							return $elm$json$Json$Decode$succeed(
								$author$project$GridLevel$Arc(
									{
										b: $author$project$GridLevel$ivec$(cx, cy, cz),
										c: $author$project$GridLevel$ivec$(fx, fy, fz),
										p: r,
										e: $author$project$GridLevel$ivec$(tx, ty, tz)
									}));
						} else {
							break _v0$2;
						}
					}
				} else {
					break _v0$2;
				}
			}
			return $elm$json$Json$Decode$fail('Not an edge');
		},
		$elm$json$Json$Decode$list($elm$json$Json$Decode$int));
	var cell = $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A3(
				$elm$json$Json$Decode$map2,
				F2(
					function (normal, loop) {
						return $author$project$GridLevel$FlatCell(
							{X: loop, k: normal});
					}),
				A2($elm$json$Json$Decode$field, 'normal', ivecDecoder),
				A2(
					$elm$json$Json$Decode$field,
					'loop',
					$elm$json$Json$Decode$list(curve))),
				A5(
				$elm$json$Json$Decode$map4,
				F4(
					function (center, axis, x, p) {
						return $author$project$GridLevel$RoundCell(
							{w: axis, b: center, u: p, m: x});
					}),
				A2($elm$json$Json$Decode$field, 'center', ivecDecoder),
				A2($elm$json$Json$Decode$field, 'axis', ivecDecoder),
				A2($elm$json$Json$Decode$field, 'x', ivecDecoder),
				A2($elm$json$Json$Decode$field, 'profile', profile))
			]));
	return A2(
		$elm$json$Json$Decode$map,
		function (cells) {
			return {V: cells};
		},
		A2(
			$elm$json$Json$Decode$field,
			'cells',
			$elm$json$Json$Decode$list(cell)));
}();
var $author$project$Minimap$mapDistance$ = function (a, b) {
	return $elm$core$Basics$sqrt(
		A2($elm$core$Basics$pow, a.m - b.m, 2) + A2($elm$core$Basics$pow, a.n - b.n, 2));
};
var $author$project$Minimap$mapDistance = F2($author$project$Minimap$mapDistance$);
var $author$project$Minimap$sameImage = 0.02;
var $author$project$Minimap$addImage$ = function (image, images) {
	return $elm$core$List$any$(
		function (other) {
			return ($author$project$Minimap$mapDistance$(image, other) - $author$project$Minimap$sameImage) < 0;
		},
		images) ? images : A2($elm$core$List$cons, image, images);
};
var $author$project$Minimap$addImage = F2($author$project$Minimap$addImage$);
var $author$project$Minimap$dot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$Minimap$dot = F2($author$project$Minimap$dot$);
var $author$project$Minimap$maxOffSurface = 0.05;
var $author$project$Minimap$sub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$Minimap$sub = F2($author$project$Minimap$sub$);
var $author$project$Minimap$fanImage$ = function (_v0, point) {
	var max = _v0.a2;
	var min = _v0.a3;
	var c = _v0.cN;
	var b = _v0.cM;
	var a = _v0.cK;
	var weights = function (_v3) {
		if (_Utils_eq(a.aq, point.aq) && (_Utils_eq(b.aq, point.aq) && _Utils_eq(c.aq, point.aq))) {
			var e2y = c.K.ad - a.K.ad;
			var e2x = c.K.aj - a.K.aj;
			var e1y = b.K.ad - a.K.ad;
			var e1x = b.K.aj - a.K.aj;
			var dy = point.K.ad - a.K.ad;
			var dx = point.K.aj - a.K.aj;
			var determinant = (e1x * e2y) - (e2x * e1y);
			return ($elm$core$Basics$abs(determinant) < 1.0e-14) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				_Utils_Tuple2(((e2y * dx) - (e2x * dy)) / determinant, ((e1x * dy) - (e1y * dx)) / determinant));
		} else {
			var e2 = $author$project$Minimap$sub$(c.gQ, a.gQ);
			var g22 = $author$project$Minimap$dot$(e2, e2);
			var e1 = $author$project$Minimap$sub$(b.gQ, a.gQ);
			var g11 = $author$project$Minimap$dot$(e1, e1);
			var g12 = $author$project$Minimap$dot$(e1, e2);
			var gram = (g11 * g22) - (g12 * g12);
			var d = $author$project$Minimap$sub$(point.gQ, a.gQ);
			var l1 = ((g22 * $author$project$Minimap$dot$(e1, d)) - (g12 * $author$project$Minimap$dot$(e2, d))) / gram;
			var l2 = ((g11 * $author$project$Minimap$dot$(e2, d)) - (g12 * $author$project$Minimap$dot$(e1, d))) / gram;
			var off = {m: (d.m - (l1 * e1.m)) - (l2 * e2.m), n: (d.n - (l1 * e1.n)) - (l2 * e2.n), o: (d.o - (l1 * e1.o)) - (l2 * e2.o)};
			return ((gram < 1.0e-14) || (($author$project$Minimap$dot$(off, off) - ($author$project$Minimap$maxOffSurface * $author$project$Minimap$maxOffSurface)) > 0)) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				_Utils_Tuple2(l1, l2));
		}
	};
	var p = point.gQ;
	var _v1 = (((p.m - min.m) < 0) || (((p.m - max.m) > 0) || (((p.n - min.n) < 0) || (((p.n - max.n) > 0) || (((p.o - min.o) < 0) || ((p.o - max.o) > 0)))))) ? $elm$core$Maybe$Nothing : weights(0);
	if (!_v1.$) {
		var _v2 = _v1.a;
		var l1 = _v2.a;
		var l2 = _v2.b;
		return (((l1 + 1.0e-3) >= 0) && (((l2 + 1.0e-3) >= 0) && ((l1 + l2) <= 1.001))) ? $elm$core$Maybe$Just(
			{m: (a.ag.m + (l1 * (b.ag.m - a.ag.m))) + (l2 * (c.ag.m - a.ag.m)), n: (a.ag.n + (l1 * (b.ag.n - a.ag.n))) + (l2 * (c.ag.n - a.ag.n))}) : $elm$core$Maybe$Nothing;
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Minimap$fanImage = F2($author$project$Minimap$fanImage$);
var $author$project$Shapes$foldWithin$ = function (box, step, initial, shapes) {
	var grid = shapes.bU;
	var clampCell = F3(
		function (first, count, i) {
			return ((i - first) < 0) ? 0 : ((((i - first) - count) >= 0) ? (count - 1) : (i - first));
		});
	var xTo = A3(
		clampCell,
		grid.cc,
		grid.b_,
		$author$project$Shapes$cellOf(box.a2.m));
	var _v0 = _Utils_Tuple2(
		A3(
			clampCell,
			grid.ce,
			grid.bE,
			$author$project$Shapes$cellOf(box.a3.o)),
		A3(
			clampCell,
			grid.ce,
			grid.bE,
			$author$project$Shapes$cellOf(box.a2.o)));
	var zFrom = _v0.a;
	var zTo = _v0.b;
	var _v1 = _Utils_Tuple2(
		A3(
			clampCell,
			grid.cd,
			grid.bD,
			$author$project$Shapes$cellOf(box.a3.n)),
		A3(
			clampCell,
			grid.cd,
			grid.bD,
			$author$project$Shapes$cellOf(box.a2.n)));
	var yFrom = _v1.a;
	var yTo = _v1.b;
	var go = F4(
		function (x, y, z, acc) {
			go:
			while (true) {
				if ((x - xTo) > 0) {
					return acc;
				} else {
					if ((y - yTo) > 0) {
						var $temp$x = x + 1,
							$temp$y = yFrom,
							$temp$z = zFrom;
						x = $temp$x;
						y = $temp$y;
						z = $temp$z;
						continue go;
					} else {
						if ((z - zTo) > 0) {
							var $temp$y = y + 1,
								$temp$z = zFrom;
							y = $temp$y;
							z = $temp$z;
							continue go;
						} else {
							var $temp$z = z + 1,
								$temp$acc = function () {
								var _v2 = $elm$core$Array$get$((((x * grid.bD) + y) * grid.bE) + z, grid.V);
								if (!_v2.$) {
									var inCell = _v2.a;
									return $elm$core$List$foldl$(step, acc, inCell);
								} else {
									return acc;
								}
							}();
							z = $temp$z;
							acc = $temp$acc;
							continue go;
						}
					}
				}
			}
		});
	return A4(
		go,
		A3(
			clampCell,
			grid.cc,
			grid.b_,
			$author$project$Shapes$cellOf(box.a3.m)),
		yFrom,
		zFrom,
		initial);
};
var $author$project$Shapes$foldWithin = F4($author$project$Shapes$foldWithin$);
var $author$project$Minimap$inBox$ = function (box, p) {
	return ((p.m - box.a3.m) >= 0) && (((p.m - box.a2.m) <= 0) && (((p.n - box.a3.n) >= 0) && (((p.n - box.a2.n) <= 0) && (((p.o - box.a3.o) >= 0) && ((p.o - box.a2.o) <= 0)))));
};
var $author$project$Minimap$inBox = F2($author$project$Minimap$inBox$);
var $author$project$Minimap$addFanImages$ = function (shapes, triangle, images) {
	return $author$project$Shapes$foldWithin$(
		{a2: triangle.a2, a3: triangle.a3},
		F2(
			function (index, acc) {
				var _v0 = $elm$core$Array$get$(index, shapes.fn);
				if (!_v0.$) {
					var point = _v0.a;
					if ($author$project$Minimap$inBox$(triangle, point.gQ)) {
						var _v1 = $author$project$Minimap$fanImage$(triangle, point);
						if (!_v1.$) {
							var image = _v1.a;
							return $elm$core$Array$set$(
								index,
								$author$project$Minimap$addImage$(
									image,
									$elm$core$Maybe$withDefault$(
										_List_Nil,
										$elm$core$Array$get$(index, acc))),
								acc);
						} else {
							return acc;
						}
					} else {
						return acc;
					}
				} else {
					return acc;
				}
			}),
		images,
		shapes);
};
var $author$project$Minimap$addFanImages = F3($author$project$Minimap$addFanImages$);
var $author$project$Minimap$distance$ = function (a, b) {
	return $elm$core$Basics$sqrt(
		(A2($elm$core$Basics$pow, a.m - b.m, 2) + A2($elm$core$Basics$pow, a.n - b.n, 2)) + A2($elm$core$Basics$pow, a.o - b.o, 2));
};
var $author$project$Minimap$distance = F2($author$project$Minimap$distance$);
var $author$project$Minimap$maxFloat$ = function (a, b) {
	return ((a - b) > 0) ? a : b;
};
var $author$project$Minimap$maxFloat = F2($author$project$Minimap$maxFloat$);
var $author$project$Minimap$minFloat$ = function (a, b) {
	return ((a - b) < 0) ? a : b;
};
var $author$project$Minimap$minFloat = F2($author$project$Minimap$minFloat$);
var $author$project$Minimap$maxFanEdge = 0.6;
var $author$project$Minimap$near$ = function (p, q) {
	return ($author$project$Minimap$distance$(p, q) - $author$project$Minimap$maxFanEdge) < 0;
};
var $author$project$Minimap$near = F2($author$project$Minimap$near$);
var $author$project$Minimap$between$ = function (left, right, triangles) {
	var last = $elm$core$Basics$min$(
		left.cm + $elm$core$Array$length(left.fn),
		right.cm + $elm$core$Array$length(right.fn)) - 2;
	var at = F2(
		function (ray, j) {
			return $elm$core$Array$get$(j - ray.cm, ray.fn);
		});
	var add = F4(
		function (a, b, c, acc) {
			return ($author$project$Minimap$near$(a.gQ, b.gQ) && ($author$project$Minimap$near$(b.gQ, c.gQ) && $author$project$Minimap$near$(c.gQ, a.gQ))) ? A2(
				$elm$core$List$cons,
				{
					cK: a,
					cM: b,
					cN: c,
					a2: {
						m: $author$project$Minimap$maxFloat$(
							a.gQ.m,
							$author$project$Minimap$maxFloat$(b.gQ.m, c.gQ.m)) + $author$project$Minimap$maxOffSurface,
						n: $author$project$Minimap$maxFloat$(
							a.gQ.n,
							$author$project$Minimap$maxFloat$(b.gQ.n, c.gQ.n)) + $author$project$Minimap$maxOffSurface,
						o: $author$project$Minimap$maxFloat$(
							a.gQ.o,
							$author$project$Minimap$maxFloat$(b.gQ.o, c.gQ.o)) + $author$project$Minimap$maxOffSurface
					},
					a3: {
						m: $author$project$Minimap$minFloat$(
							a.gQ.m,
							$author$project$Minimap$minFloat$(b.gQ.m, c.gQ.m)) - $author$project$Minimap$maxOffSurface,
						n: $author$project$Minimap$minFloat$(
							a.gQ.n,
							$author$project$Minimap$minFloat$(b.gQ.n, c.gQ.n)) - $author$project$Minimap$maxOffSurface,
						o: $author$project$Minimap$minFloat$(
							a.gQ.o,
							$author$project$Minimap$minFloat$(b.gQ.o, c.gQ.o)) - $author$project$Minimap$maxOffSurface
					}
				},
				acc) : acc;
		});
	var go = F2(
		function (j, acc) {
			go:
			while (true) {
				if ((j - last) > 0) {
					return acc;
				} else {
					var _v0 = _Utils_Tuple2(
						_Utils_Tuple2(
							A2(at, left, j),
							A2(at, right, j)),
						_Utils_Tuple2(
							A2(at, right, j + 1),
							A2(at, left, j + 1)));
					if ((((!_v0.a.a.$) && (!_v0.a.b.$)) && (!_v0.b.a.$)) && (!_v0.b.b.$)) {
						var _v1 = _v0.a;
						var a = _v1.a.a;
						var b = _v1.b.a;
						var _v2 = _v0.b;
						var c = _v2.a.a;
						var d = _v2.b.a;
						var $temp$j = j + 1,
							$temp$acc = A4(
							add,
							a,
							c,
							d,
							A4(add, a, b, c, acc));
						j = $temp$j;
						acc = $temp$acc;
						continue go;
					} else {
						var $temp$j = j + 1;
						j = $temp$j;
						continue go;
					}
				}
			}
		});
	return A2(
		go,
		$elm$core$Basics$max$(left.cm, right.cm),
		triangles);
};
var $author$project$Minimap$between = F3($author$project$Minimap$between$);
var $author$project$Surface$fanSpacing = 0.15;
var $author$project$Minimap$fanTriangles = function (groups) {
	var pointsOf = function (ray) {
		return {
			cm: ray.f1,
			fn: $elm$core$Array$fromList(
				$elm$core$List$indexedMap$(
					F2(
						function (i, sample) {
							var distanceOnMap = (ray.f1 + i) * $author$project$Surface$fanSpacing;
							return {
								K: sample.K,
								ag: {
									m: distanceOnMap * $elm$core$Basics$cos(ray.fS),
									n: distanceOnMap * $elm$core$Basics$sin(ray.fS)
								},
								aq: sample.aq,
								gQ: sample.gQ
							};
						}),
					ray.iX))
		};
	};
	var addGroup = F2(
		function (rays, triangles) {
			var _v0 = $elm$core$List$map$(pointsOf, rays);
			if (_v0.b) {
				var first = _v0.a;
				var rest = _v0.b;
				return $elm$core$List$foldl$(
					F2(
						function (right, _v1) {
							var left = _v1.a;
							var acc = _v1.b;
							return _Utils_Tuple2(
								right,
								$author$project$Minimap$between$(left, right, acc));
						}),
					_Utils_Tuple2(first, triangles),
					rest).b;
			} else {
				return triangles;
			}
		});
	return $elm$core$List$foldl$(addGroup, _List_Nil, groups);
};
var $ianmackenzie$elm_units$Length$inMeters = function (_v0) {
	var numMeters = _v0;
	return numMeters;
};
var $author$project$Surface$cmul$ = function (p, q) {
	return {ad: (p.aj * q.ad) + (p.ad * q.aj), aj: (p.aj * q.aj) - (p.ad * q.ad)};
};
var $author$project$Surface$cmul = F2($author$project$Surface$cmul$);
var $author$project$Surface$cabs = function (p) {
	return $elm$core$Basics$sqrt((p.aj * p.aj) + (p.ad * p.ad));
};
var $author$project$Surface$cadd$ = function (p, q) {
	return {ad: p.ad + q.ad, aj: p.aj + q.aj};
};
var $author$project$Surface$cadd = F2($author$project$Surface$cadd$);
var $author$project$Surface$csub$ = function (p, q) {
	return {ad: p.ad - q.ad, aj: p.aj - q.aj};
};
var $author$project$Surface$csub = F2($author$project$Surface$csub$);
var $author$project$Surface$distanceToSegment$ = function (p, q) {
	var d = $author$project$Surface$csub$(q, p);
	var lengthSquared = (d.aj * d.aj) + (d.ad * d.ad);
	var t = (lengthSquared < 1.0e-18) ? 0 : $elm$core$Basics$clamp$(0, 1, -(((p.aj * d.aj) + (p.ad * d.ad)) / lengthSquared));
	return $author$project$Surface$cabs(
		$author$project$Surface$cadd$(
			p,
			$author$project$Surface$cscale$(t, d)));
};
var $author$project$Surface$distanceToSegment = F2($author$project$Surface$distanceToSegment$);
var $author$project$Surface$edgeFractions$ = function (piece, edgeIndex) {
	var count = function () {
		if (!piece.$) {
			var flat = piece.a;
			var _v1 = $elm$core$Array$get$(edgeIndex, flat.bS);
			if ((!_v1.$) && (_v1.a.$ === 1)) {
				return 64;
			} else {
				return 1;
			}
		} else {
			return 1;
		}
	}();
	return $elm$core$List$map$(
		function (i) {
			return i / count;
		},
		$elm$core$List$range$(0, count));
};
var $author$project$Surface$edgeFractions = F2($author$project$Surface$edgeFractions$);
var $author$project$Surface$holeEdges = function (piece) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$List$filterMap$(
			function (_v1) {
				var index = _v1.a;
				var edge = _v1.b;
				if (edge.$ === 1) {
					var swept = edge.a.aI;
					return (_Utils_cmp(swept, ((-2) * $elm$core$Basics$pi) + 1.0e-6) < 0) ? $elm$core$Maybe$Just(index) : $elm$core$Maybe$Nothing;
				} else {
					return $elm$core$Maybe$Nothing;
				}
			},
			$elm$core$Array$toIndexedList(flat.bS));
	} else {
		return _List_Nil;
	}
};
var $author$project$Surface$intersectWindows$ = function (first, second) {
	if (_Utils_cmp(first.f5, $elm$core$Basics$pi) > -1) {
		return second;
	} else {
		if (_Utils_cmp(second.f5, $elm$core$Basics$pi) > -1) {
			return first;
		} else {
			var offset = $author$project$Surface$wrapAngle((second.b - first.b) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
			var to = $elm$core$Basics$min$(first.f5, offset + second.f5);
			var from = $elm$core$Basics$max$(-first.f5, offset - second.f5);
			return {
				b: first.b + ((from + to) / 2),
				f5: $elm$core$Basics$max$(0, (to - from) / 2)
			};
		}
	}
};
var $author$project$Surface$intersectWindows = F2($author$project$Surface$intersectWindows$);
var $author$project$Surface$isNewPlacement$ = function (child, placed) {
	return $elm$core$List$all$(
		function (other) {
			return (!_Utils_eq(other.aq, child.aq)) || (($author$project$Surface$cabs(
				$author$project$Surface$csub$(other.aG, child.aG)) > 1.0e-6) || (($author$project$Surface$cabs(
				$author$project$Surface$csub$(other.gG, child.gG)) > 1.0e-6) || (($elm$core$Basics$abs(
				$author$project$Surface$wrapAngle((other.fM.b - child.fM.b) + $elm$core$Basics$pi) - $elm$core$Basics$pi) > 1.0e-6) || ($elm$core$Basics$abs(
				$elm$core$Basics$min$($elm$core$Basics$pi, other.fM.f5) - $elm$core$Basics$min$($elm$core$Basics$pi, child.fM.f5)) > 1.0e-6))));
		},
		placed);
};
var $author$project$Surface$isNewPlacement = F2($author$project$Surface$isNewPlacement$);
var $author$project$Surface$isRigid = function (piece) {
	if (!piece.$) {
		return true;
	} else {
		var feature = piece.a;
		return (!_Utils_eq(feature.jg, $elm$core$Maybe$Nothing)) && $elm$core$List$all$(
			function (segment) {
				if (!segment.$) {
					var dr = segment.a.N;
					return $elm$core$Basics$abs(dr) < 1.0e-9;
				} else {
					return false;
				}
			},
			feature.gX);
	}
};
var $author$project$Surface$maxPlacements = 64;
var $elm$core$List$member$ = function (x, xs) {
	return $elm$core$List$any$(
		function (a) {
			return _Utils_eq(a, x);
		},
		xs);
};
var $elm$core$List$member = F2($elm$core$List$member$);
var $author$project$Surface$cdiv$ = function (p, q) {
	var denominator = (q.aj * q.aj) + (q.ad * q.ad);
	return {ad: ((p.ad * q.aj) - (p.aj * q.ad)) / denominator, aj: ((p.aj * q.aj) + (p.ad * q.ad)) / denominator};
};
var $author$project$Surface$cdiv = F2($author$project$Surface$cdiv$);
var $author$project$Surface$holeOnMap$ = function (piece, placement) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$Maybe$andThen$(
			function (edge) {
				if (edge.$ === 1) {
					var r = edge.a.f;
					var cy = edge.a.aw;
					var cx = edge.a.av;
					return $elm$core$Maybe$Just(
						{
							b: $author$project$Surface$cadd$(
								$author$project$Surface$cmul$(
									placement.aG,
									{ad: cy, aj: cx}),
								placement.gG),
							p: r * $author$project$Surface$cabs(placement.aG)
						});
				} else {
					return $elm$core$Maybe$Nothing;
				}
			},
			$elm$core$Maybe$andThen$(
				function (index) {
					return $elm$core$Array$get$(index, flat.bS);
				},
				$elm$core$List$head(
					$author$project$Surface$holeEdges(piece))));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Surface$holeOnMap = F2($author$project$Surface$holeOnMap$);
var $author$project$Surface$placeOnMap$ = function (placement, chart) {
	return $author$project$Surface$cadd$(
		$author$project$Surface$cmul$(placement.aG, chart),
		placement.gG);
};
var $author$project$Surface$placeOnMap = F2($author$project$Surface$placeOnMap$);
var $author$project$Surface$placeChild$ = function (parent, parentPiece, edgeIndex, childIndex, childEdge, childPiece, distance, window) {
	var parentOutput = function (p) {
		var located = $author$project$Surface$locateOnEdge$(parentPiece, edgeIndex, p);
		return $author$project$Surface$placeOnMap$(
			parent,
			$author$project$Surface$localChart$(parentPiece, located.cK, located.cM));
	};
	var childChart = function (p) {
		var located = $author$project$Surface$locateOnEdge$(childPiece, childEdge, p);
		return $author$project$Surface$localChart$(childPiece, located.cK, located.cM);
	};
	var _v0 = $elm$core$List$filterMap$(
		A2($author$project$Surface$edgeSample, parentPiece, edgeIndex),
		_List_fromArray(
			[0.1, 0.9]));
	if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
		var p1 = _v0.a;
		var _v1 = _v0.b;
		var p2 = _v1.a;
		var z2 = childChart(p2);
		var z1 = childChart(p1);
		var w2 = parentOutput(p2);
		var w1 = parentOutput(p1);
		if ($author$project$Surface$cabs(
			$author$project$Surface$csub$(z2, z1)) > 1.0e-9) {
			var scale_ = $author$project$Surface$cdiv$(
				$author$project$Surface$csub$(w2, w1),
				$author$project$Surface$csub$(z2, z1));
			var offset = $author$project$Surface$csub$(
				w1,
				$author$project$Surface$cmul$(scale_, z1));
			return $elm$core$Maybe$Just(
				{
					bO: distance,
					h3: $author$project$Surface$holeOnMap$(
						childPiece,
						{gG: offset, aG: scale_}),
					gG: offset,
					aq: childIndex,
					aG: scale_,
					fM: window
				});
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Surface$placeChild = F8($author$project$Surface$placeChild$);
var $author$project$Surface$subtractWindow$ = function (cut, window) {
	if (_Utils_cmp(cut.f5, $elm$core$Basics$pi) > -1) {
		return _List_Nil;
	} else {
		if (_Utils_cmp(window.f5, $elm$core$Basics$pi) > -1) {
			return _List_fromArray(
				[
					{b: cut.b + $elm$core$Basics$pi, f5: $elm$core$Basics$pi - cut.f5}
				]);
		} else {
			var remove = F2(
				function (_v3, intervals) {
					var low = _v3.a;
					var high = _v3.b;
					return $elm$core$List$concatMap$(
						function (_v1) {
							var from = _v1.a;
							var to = _v1.b;
							return ((_Utils_cmp(high, from) < 1) || (_Utils_cmp(low, to) > -1)) ? _List_fromArray(
								[
									_Utils_Tuple2(from, to)
								]) : $elm$core$List$filter$(
								function (_v2) {
									var f = _v2.a;
									var t = _v2.b;
									return _Utils_cmp(t, f) > 0;
								},
								_List_fromArray(
									[
										_Utils_Tuple2(from, low),
										_Utils_Tuple2(high, to)
									]));
						},
						intervals);
				});
			var offset = $author$project$Surface$wrapAngle((cut.b - window.b) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
			return $elm$core$List$map$(
				function (_v0) {
					var from = _v0.a;
					var to = _v0.b;
					return {b: window.b + ((from + to) / 2), f5: (to - from) / 2};
				},
				$elm$core$List$foldl$(
					F2(
						function (turns, intervals) {
							return A2(
								remove,
								_Utils_Tuple2((offset - cut.f5) + ((turns * 2) * $elm$core$Basics$pi), (offset + cut.f5) + ((turns * 2) * $elm$core$Basics$pi)),
								intervals);
						}),
					_List_fromArray(
						[
							_Utils_Tuple2(-window.f5, window.f5)
						]),
					_List_fromArray(
						[-1, 0, 1])));
		}
	}
};
var $author$project$Surface$subtractWindow = F2($author$project$Surface$subtractWindow$);
var $author$project$Surface$fullWindow = {b: 0, f5: $elm$core$Basics$pi};
var $author$project$Surface$windowOf = function (points) {
	var _v0 = $elm$core$List$map$(
		function (p) {
			return A2($elm$core$Basics$atan2, p.ad, p.aj);
		},
		$elm$core$List$filter$(
			function (p) {
				return $author$project$Surface$cabs(p) > 1.0e-9;
			},
			points));
	if (_v0.b) {
		var first = _v0.a;
		var rest = _v0.b;
		var _v1 = $elm$core$List$foldl$(
			F2(
				function (angle, _v2) {
					var previous = _v2.a;
					var lowSoFar = _v2.b;
					var highSoFar = _v2.c;
					var unwrapped = (previous + $author$project$Surface$wrapAngle((angle - previous) + $elm$core$Basics$pi)) - $elm$core$Basics$pi;
					return _Utils_Tuple3(
						unwrapped,
						$elm$core$Basics$min$(lowSoFar, unwrapped),
						$elm$core$Basics$max$(highSoFar, unwrapped));
				}),
			_Utils_Tuple3(first, first, first),
			rest);
		var low = _v1.b;
		var high = _v1.c;
		return (_Utils_cmp(high - low, (2 * $elm$core$Basics$pi) - 1.0e-3) > -1) ? $author$project$Surface$fullWindow : {b: (low + high) / 2, f5: (high - low) / 2};
	} else {
		return $author$project$Surface$fullWindow;
	}
};
var $author$project$Surface$flattenHelper$ = function (radius, pieces, seams, queue, placed, curved) {
	flattenHelper:
	while (true) {
		var _v0 = A2(
			$elm$core$List$sortBy,
			A2(
				$elm$core$Basics$composeR,
				function ($) {
					return $.H;
				},
				function ($) {
					return $.bO;
				}),
			queue);
		if (!_v0.b) {
			return _Utils_Tuple2(
				$elm$core$List$reverse(placed),
				curved);
		} else {
			var route = _v0.a.fr;
			var enteredThrough = _v0.a.e1;
			var placement = _v0.a.H;
			var rest = _v0.b;
			var _v1 = $elm$core$Array$get$(placement.aq, pieces);
			if (!_v1.$) {
				var parentPiece = _v1.a;
				var edgeOnMap = function (edgeIndex) {
					return $elm$core$List$map$(
						function (p) {
							var located = $author$project$Surface$locateOnEdge$(parentPiece, edgeIndex, p);
							return $author$project$Surface$placeOnMap$(
								placement,
								$author$project$Surface$localChart$(parentPiece, located.cK, located.cM));
						},
						$elm$core$List$filterMap$(
							A2($author$project$Surface$edgeSample, parentPiece, edgeIndex),
							$author$project$Surface$edgeFractions$(parentPiece, edgeIndex)));
				};
				var shadows = $elm$core$List$map$(
					function (edgeIndex) {
						return _Utils_Tuple2(
							edgeIndex,
							$author$project$Surface$windowOf(
								edgeOnMap(edgeIndex)));
					},
					$author$project$Surface$holeEdges(parentPiece));
				var _v2 = $elm$core$List$foldl$(
					F2(
						function (edgeIndex, unchanged) {
							var queueAcc = unchanged.a;
							var placedAcc = unchanged.b;
							var curvedAcc = unchanged.c;
							var _v3 = $elm$core$Maybe$andThen$(
								$elm$core$Basics$identity,
								$elm$core$Maybe$andThen$(
									$elm$core$Array$get(edgeIndex),
									$elm$core$Array$get$(placement.aq, seams)));
							if (!_v3.$) {
								var _v4 = _v3.a;
								var childIndex = _v4.a;
								var childEdge = _v4.b;
								var points = edgeOnMap(edgeIndex);
								var visible = $elm$core$List$filter$(
									function (window) {
										return window.f5 > 1.0e-6;
									},
									$elm$core$List$foldl$(
										F2(
											function (_v9, windows) {
												var shadow = _v9.b;
												return $elm$core$List$concatMap$(
													$author$project$Surface$subtractWindow(shadow),
													windows);
											}),
										_List_fromArray(
											[
												$author$project$Surface$intersectWindows$(
												placement.fM,
												$author$project$Surface$windowOf(points))
											]),
										$elm$core$List$filter$(
											function (_v8) {
												var holeEdge = _v8.a;
												return !_Utils_eq(holeEdge, edgeIndex);
											},
											shadows)));
								var distance = $elm$core$List$foldl$(
									$elm$core$Basics$min,
									1 / 0,
									A3(
										$elm$core$List$map2,
										$author$project$Surface$distanceToSegment,
										points,
										$elm$core$List$drop$(1, points)));
								if (_Utils_eq(edgeIndex, enteredThrough) || (_Utils_cmp(distance, radius) > -1)) {
									return unchanged;
								} else {
									var _v5 = $elm$core$Array$get$(childIndex, pieces);
									if (!_v5.$) {
										var childPiece = _v5.a;
										return (!$author$project$Surface$isRigid(childPiece)) ? _Utils_Tuple3(
											queueAcc,
											placedAcc,
											_Utils_ap(visible, curvedAcc)) : ($elm$core$List$member$(childIndex, route) ? unchanged : $elm$core$List$foldl$(
											F2(
												function (window, _v6) {
													var q = _v6.a;
													var p = _v6.b;
													var c = _v6.c;
													var _v7 = $author$project$Surface$placeChild$(
														placement,
														parentPiece,
														edgeIndex,
														childIndex,
														childEdge,
														childPiece,
														$elm$core$Basics$max$(distance, placement.bO),
														window);
													if (!_v7.$) {
														var child = _v7.a;
														return ((_Utils_cmp(
															$elm$core$List$length(p),
															$author$project$Surface$maxPlacements) < 0) && $author$project$Surface$isNewPlacement$(child, p)) ? _Utils_Tuple3(
															A2(
																$elm$core$List$cons,
																{
																	e1: childEdge,
																	H: child,
																	fr: A2($elm$core$List$cons, childIndex, route)
																},
																q),
															A2($elm$core$List$cons, child, p),
															c) : _Utils_Tuple3(q, p, c);
													} else {
														return _Utils_Tuple3(q, p, c);
													}
												}),
											unchanged,
											visible));
									} else {
										return unchanged;
									}
								}
							} else {
								return unchanged;
							}
						}),
					_Utils_Tuple3(rest, placed, curved),
					$elm$core$List$range$(
						0,
						$author$project$Surface$edgeCount(parentPiece) - 1));
				var newQueue = _v2.a;
				var newPlaced = _v2.b;
				var newCurved = _v2.c;
				var $temp$queue = newQueue,
					$temp$placed = newPlaced,
					$temp$curved = newCurved;
				queue = $temp$queue;
				placed = $temp$placed;
				curved = $temp$curved;
				continue flattenHelper;
			} else {
				var $temp$queue = rest;
				queue = $temp$queue;
				continue flattenHelper;
			}
		}
	}
};
var $author$project$Surface$flattenHelper = F6($author$project$Surface$flattenHelper$);
var $author$project$Surface$fanAngle = 0.08;
var $author$project$Surface$fanGap = 0.5;
var $elm$core$Basics$isInfinite = _Basics_isInfinite;
var $elm$core$List$map3 = _List_map3;
var $author$project$Surface$finishGroup = function (rays) {
	var firsts = $elm$core$List$map$(
		function (ray) {
			return $elm$core$Basics$isInfinite(ray.a$) ? 1000000 : $elm$core$Basics$max$(
				0,
				$elm$core$Basics$floor(ray.a$ / $author$project$Surface$fanSpacing) - 2);
		},
		rays);
	var neighbourMin = A4(
		$elm$core$List$map3,
		F3(
			function (previous, current, next) {
				return $elm$core$Basics$min$(
					previous,
					$elm$core$Basics$min$(current, next));
			}),
		_Utils_ap(
			$elm$core$List$take$(1, firsts),
			firsts),
		firsts,
		_Utils_ap(
			$elm$core$List$drop$(1, firsts),
			$elm$core$List$drop$(
				$elm$core$List$length(firsts) - 1,
				firsts)));
	return A3(
		$elm$core$List$map2,
		F2(
			function (ray, first) {
				return {
					fS: ray.fS,
					f1: first,
					iX: $elm$core$List$drop$(first, ray.iX)
				};
			}),
		rays,
		neighbourMin);
};
var $author$project$Surface$maxFanRefinement = 3;
var $author$project$Surface$fanMargin = 0.02;
var $author$project$Surface$mergeWindows = function (windows) {
	var sorted = A2(
		$elm$core$List$sortBy,
		$elm$core$Tuple$first,
		$elm$core$List$map$(
			function (window) {
				var from = $author$project$Surface$wrapAngle((window.b - window.f5) - $author$project$Surface$fanMargin);
				return _Utils_Tuple2(from, from + (2 * (window.f5 + $author$project$Surface$fanMargin)));
			},
			windows));
	var merged = $elm$core$List$foldl$(
		F2(
			function (_v6, acc) {
				var from = _v6.a;
				var to = _v6.b;
				if (acc.b) {
					var _v8 = acc.a;
					var lastFrom = _v8.a;
					var lastTo = _v8.b;
					var others = acc.b;
					return (_Utils_cmp(from, lastTo) < 1) ? A2(
						$elm$core$List$cons,
						_Utils_Tuple2(
							lastFrom,
							$elm$core$Basics$max$(to, lastTo)),
						others) : A2(
						$elm$core$List$cons,
						_Utils_Tuple2(from, to),
						acc);
				} else {
					return _List_fromArray(
						[
							_Utils_Tuple2(from, to)
						]);
				}
			}),
		_List_Nil,
		sorted);
	var wrapped = function () {
		var _v1 = _Utils_Tuple2(
			merged,
			$elm$core$List$reverse(merged));
		if (_v1.a.b && _v1.b.b) {
			var _v2 = _v1.a;
			var _v3 = _v2.a;
			var lastFrom = _v3.a;
			var lastTo = _v3.b;
			var _v4 = _v1.b;
			var _v5 = _v4.a;
			var firstFrom = _v5.a;
			var firstTo = _v5.b;
			return (($elm$core$List$length(merged) > 1) && (_Utils_cmp(lastTo, firstFrom + (2 * $elm$core$Basics$pi)) > -1)) ? _Utils_ap(
				$elm$core$List$take$(
					$elm$core$List$length(merged) - 2,
					$elm$core$List$drop$(
						1,
						$elm$core$List$reverse(merged))),
				_List_fromArray(
					[
						_Utils_Tuple2(
						lastFrom,
						$elm$core$Basics$max$(lastTo, firstTo + (2 * $elm$core$Basics$pi)))
					])) : $elm$core$List$reverse(merged);
		} else {
			return _List_Nil;
		}
	}();
	return $elm$core$List$any$(
		function (_v0) {
			var from = _v0.a;
			var to = _v0.b;
			return _Utils_cmp(to - from, 2 * $elm$core$Basics$pi) > -1;
		},
		wrapped) ? _List_fromArray(
		[
			_Utils_Tuple2(0, 2 * $elm$core$Basics$pi)
		]) : wrapped;
};
var $author$project$Surface$spread$ = function (first, second) {
	return $elm$core$List$foldl$(
		$elm$core$Basics$max,
		0,
		A3(
			$elm$core$List$map2,
			F2(
				function (p, q) {
					return $author$project$Surface$lengthOf(
						$author$project$Surface$sub$(p.gQ, q.gQ));
				}),
			first,
			second));
};
var $author$project$Surface$spread = F2($author$project$Surface$spread$);
var $elm$core$Basics$acos = _Basics_acos;
var $author$project$Surface$edgeTangent2d$ = function (edge, a, b) {
	if (!edge.$) {
		var by = edge.a.aX;
		var bx = edge.a.aW;
		var ay = edge.a.aM;
		var ax = edge.a.aL;
		var l = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, bx - ax, 2) + A2($elm$core$Basics$pow, by - ay, 2));
		return _Utils_Tuple2((bx - ax) / l, (by - ay) / l);
	} else {
		var swept = edge.a.aI;
		var cy = edge.a.aw;
		var cx = edge.a.av;
		var dir = (swept < 0) ? (-1) : 1;
		var angle = A2($elm$core$Basics$atan2, b - cy, a - cx);
		return _Utils_Tuple2(
			(-dir) * $elm$core$Basics$sin(angle),
			dir * $elm$core$Basics$cos(angle));
	}
};
var $author$project$Surface$edgeTangent2d = F3($author$project$Surface$edgeTangent2d$);
var $author$project$Surface$edgeFrame$ = function (piece, edgeIndex, a, b) {
	if (!piece.$) {
		var flat = piece.a;
		var _v1 = function () {
			var _v2 = $elm$core$Array$get$(edgeIndex, flat.bS);
			if (!_v2.$) {
				var edge = _v2.a;
				return $author$project$Surface$edgeTangent2d$(edge, a, b);
			} else {
				return _Utils_Tuple2(1, 0);
			}
		}();
		var tx = _v1.a;
		var ty = _v1.b;
		var tangent = $author$project$Surface$combine$(tx, flat.a9, ty, flat.bb);
		return {
			ig: $author$project$Surface$cross$(flat.s, tangent),
			cE: tangent
		};
	} else {
		var feature = piece.a;
		var basis = $author$project$Surface$featureBasis$(feature, a, b);
		switch (edgeIndex) {
			case 0:
				return {ig: basis.ax, cE: basis.ay};
			case 1:
				return {
					ig: $author$project$Surface$scale$(-1, basis.ax),
					cE: basis.ay
				};
			case 2:
				return {ig: basis.ay, cE: basis.ax};
			default:
				return {
					ig: $author$project$Surface$scale$(-1, basis.ay),
					cE: basis.ax
				};
		}
	}
};
var $author$project$Surface$edgeFrame = F4($author$project$Surface$edgeFrame$);
var $author$project$Surface$headingToVec$ = function (frame, heading) {
	return $author$project$Surface$combine$(
		$elm$core$Basics$cos(heading),
		frame.bP,
		$elm$core$Basics$sin(heading),
		frame.bQ);
};
var $author$project$Surface$headingToVec = F2($author$project$Surface$headingToVec$);
var $author$project$Surface$vecToHeading$ = function (frame, direction) {
	return A2(
		$elm$core$Basics$atan2,
		$author$project$Surface$dot$(direction, frame.bQ),
		$author$project$Surface$dot$(direction, frame.bP));
};
var $author$project$Surface$vecToHeading = F2($author$project$Surface$vecToHeading$);
var $author$project$Surface$crossSeam$ = function (piece, edgeIndex, point, other, otherIndex, otherEdge) {
	var frame = $author$project$Surface$tangentFrame$(piece, point.cK, point.cM);
	var located = $author$project$Surface$locateOnEdge$(other, otherEdge, frame.L);
	var otherFrame = $author$project$Surface$tangentFrame$(other, located.cK, located.cM);
	var direction = $author$project$Surface$headingToVec$(frame, point.i);
	var _v0 = $author$project$Surface$edgeFrame$(other, otherEdge, located.cK, located.cM);
	var inward = _v0.ig;
	var tangent = _v0.cE;
	var along = $author$project$Surface$dot$(direction, tangent);
	var across = $elm$core$Basics$sqrt(
		$elm$core$Basics$max$(1.0e-12, 1 - (along * along)));
	return {
		cK: located.cK,
		cM: located.cM,
		i: $author$project$Surface$vecToHeading$(
			otherFrame,
			$author$project$Surface$combine$(along, tangent, across, inward)),
		aq: otherIndex
	};
};
var $author$project$Surface$crossSeam = F6($author$project$Surface$crossSeam$);
var $author$project$Surface$emitSamples$ = function (context, travelled, until, at, index, samples) {
	emitSamples:
	while (true) {
		if (((index - context.aZ) <= 0) && (((index * $author$project$Surface$fanSpacing) - until) <= 1.0e-9)) {
			var $temp$index = index + 1,
				$temp$samples = A2(
				$elm$core$List$cons,
				at((index * $author$project$Surface$fanSpacing) - travelled),
				samples);
			index = $temp$index;
			samples = $temp$samples;
			continue emitSamples;
		} else {
			return _Utils_Tuple2(index, samples);
		}
	}
};
var $author$project$Surface$emitSamples = F6($author$project$Surface$emitSamples$);
var $author$project$Surface$Cylinder = function (a) {
	return {$: 0, a: a};
};
var $author$project$Surface$Revolved = {$: 2};
var $author$project$Surface$Sphere$ = function (a, b) {
	return {$: 1, a: a, b: b};
};
var $author$project$Surface$Sphere = F2($author$project$Surface$Sphere$);
var $author$project$Surface$featureShape = function (feature) {
	var _v0 = feature.gX;
	_v0$2:
	while (true) {
		if (_v0.b) {
			if (!_v0.a.$) {
				if (!_v0.b.b) {
					var dr = _v0.a.a.N;
					var r0 = _v0.a.a.b2;
					return ($elm$core$Basics$abs(dr) < 1.0e-9) ? $author$project$Surface$Cylinder(r0) : $author$project$Surface$Revolved;
				} else {
					break _v0$2;
				}
			} else {
				if (!_v0.b.b) {
					var radius = _v0.a.a.p;
					var ch = _v0.a.a.cg;
					var cr = _v0.a.a.bM;
					return (($elm$core$Basics$abs(cr) < 1.0e-9) && (_Utils_cmp(
						$author$project$Surface$sweepRange(feature).b - $author$project$Surface$sweepStart(feature),
						$elm$core$Basics$pi + 1.0e-9) < 1)) ? $author$project$Surface$Sphere$(
						$author$project$Surface$add$(
							feature.z,
							$author$project$Surface$scale$(ch, feature.an)),
						radius) : $author$project$Surface$Revolved;
				} else {
					break _v0$2;
				}
			}
		} else {
			break _v0$2;
		}
	}
	return $author$project$Surface$Revolved;
};
var $author$project$Surface$firstViolation$ = function (feature, before, after) {
	var fraction = F3(
		function (start, end, bound) {
			return (!((end - start) - 0)) ? 0 : $author$project$Surface$clampFloat$(0, 1, (bound - start) / (end - start));
		});
	var profileViolations = (after.a < 0) ? _List_fromArray(
		[
			_Utils_Tuple2(
			0,
			A3(fraction, before.a, after.a, 0))
		]) : (((after.a - feature.aR) > 0) ? _List_fromArray(
		[
			_Utils_Tuple2(
			1,
			A3(fraction, before.a, after.a, feature.aR))
		]) : _List_Nil);
	var sweepViolations = function () {
		var _v3 = feature.jg;
		if (!_v3.$) {
			var to = _v3.a.e;
			var from = _v3.a.c;
			return ((after.d - from) < 0) ? _List_fromArray(
				[
					_Utils_Tuple2(
					2,
					A3(fraction, before.d, after.d, from))
				]) : (((after.d - to) > 0) ? _List_fromArray(
				[
					_Utils_Tuple2(
					3,
					A3(fraction, before.d, after.d, to))
				]) : _List_Nil);
		} else {
			return _List_Nil;
		}
	}();
	return $elm$core$List$foldl$(
		F2(
			function (_v0, best) {
				var edge = _v0.a;
				var f = _v0.b;
				if (!best.$) {
					var _v2 = best.a;
					var bestF = _v2.b;
					return ((f - bestF) < 0) ? $elm$core$Maybe$Just(
						_Utils_Tuple2(edge, f)) : best;
				} else {
					return $elm$core$Maybe$Just(
						_Utils_Tuple2(edge, f));
				}
			}),
		$elm$core$Maybe$Nothing,
		_Utils_ap(profileViolations, sweepViolations));
};
var $author$project$Surface$firstViolation = F3($author$project$Surface$firstViolation$);
var $author$project$Surface$rayExit$ = function (edge, px, py, dx, dy) {
	if (!edge.$) {
		var by = edge.a.aX;
		var bx = edge.a.aW;
		var ay = edge.a.aM;
		var ax = edge.a.aL;
		var ey = by - ay;
		var ex = bx - ax;
		var denominator = (dx * ey) - (dy * ex);
		if (denominator <= 1.0e-12) {
			return $elm$core$Maybe$Nothing;
		} else {
			var u = (((ax - px) * dy) - ((ay - py) * dx)) / denominator;
			var t = (((ax - px) * ey) - ((ay - py) * ex)) / denominator;
			return (((t + 1.0e-9) > 0) && (((u + 1.0e-9) >= 0) && (_Utils_cmp(u, 1 + 1.0e-9) < 1))) ? $elm$core$Maybe$Just(
				$elm$core$Basics$max$(0, t)) : $elm$core$Maybe$Nothing;
		}
	} else {
		var swept = edge.a.aI;
		var a0 = edge.a.S;
		var r = edge.a.f;
		var cy = edge.a.aw;
		var cx = edge.a.av;
		var oy = py - cy;
		var ox = px - cx;
		var dir = (swept < 0) ? (-1) : 1;
		var c = ((ox * ox) + (oy * oy)) - (r * r);
		var b = (ox * dx) + (oy * dy);
		var discriminant = (b * b) - c;
		if (discriminant < 0) {
			return $elm$core$Maybe$Nothing;
		} else {
			var root = $elm$core$Basics$sqrt(discriminant);
			var check = function (t) {
				var hy = oy + (t * dy);
				var inwardY = (-dir) * hy;
				var hx = ox + (t * dx);
				var inwardX = (-dir) * hx;
				return (((t + 1.0e-9) > 0) && ((((dx * inwardX) + (dy * inwardY)) < 0) && $author$project$Surface$onArc$(
					a0,
					swept,
					A2($elm$core$Basics$atan2, hy, hx)))) ? $elm$core$Maybe$Just(
					$elm$core$Basics$max$(0, t)) : $elm$core$Maybe$Nothing;
			};
			var _v1 = _Utils_Tuple2(
				check((-b) - root),
				check((-b) + root));
			if (!_v1.a.$) {
				if (!_v1.b.$) {
					var t0 = _v1.a.a;
					var t1 = _v1.b.a;
					return $elm$core$Maybe$Just(
						$elm$core$Basics$min$(t0, t1));
				} else {
					var t0 = _v1.a.a;
					var _v2 = _v1.b;
					return $elm$core$Maybe$Just(t0);
				}
			} else {
				var _v3 = _v1.a;
				var maybeT1 = _v1.b;
				return maybeT1;
			}
		}
	}
};
var $author$project$Surface$rayExit = F5($author$project$Surface$rayExit$);
var $author$project$Surface$flatExit$ = function (flat, px, py, dx, dy) {
	return $elm$core$Array$foldl$(
		F2(
			function (edge, _v0) {
				var index = _v0.a;
				var best = _v0.b;
				return _Utils_Tuple2(
					index + 1,
					function () {
						var _v1 = $author$project$Surface$rayExit$(edge, px, py, dx, dy);
						if (!_v1.$) {
							var t = _v1.a;
							if (!best.$) {
								var _v3 = best.a;
								var bestT = _v3.b;
								return ((t - bestT) < 0) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(index, t)) : best;
							} else {
								return $elm$core$Maybe$Just(
									_Utils_Tuple2(index, t));
							}
						} else {
							return best;
						}
					}());
			}),
		_Utils_Tuple2(0, $elm$core$Maybe$Nothing),
		flat.bS).b;
};
var $author$project$Surface$flatExit = F5($author$project$Surface$flatExit$);
var $author$project$Surface$insideSweep$ = function (feature, theta) {
	var _v0 = feature.jg;
	if (!_v0.$) {
		var to = _v0.a.e;
		var from = _v0.a.c;
		return ($author$project$Surface$wrapAngle(theta - from) - (to - from)) <= 1.0e-9;
	} else {
		return true;
	}
};
var $author$project$Surface$insideSweep = F2($author$project$Surface$insideSweep$);
var $author$project$Surface$leavePole$ = function (feature, state) {
	var p = $author$project$Surface$profileAt$(feature, state.a);
	var atStart = (state.a - $author$project$Surface$tolerance) < 0;
	var atEnd = (state.a - (feature.aR - $author$project$Surface$tolerance)) > 0;
	if ((($elm$core$Basics$abs(p.f) - $author$project$Surface$tolerance) < 0) && (atStart || atEnd)) {
		var outwardSign = atStart ? p.N : (-p.N);
		var basis = $author$project$Surface$featureBasis$(feature, state.d, state.a);
		var direction = $author$project$Surface$combine$(
			$elm$core$Basics$cos(state.r),
			basis.ax,
			$elm$core$Basics$sin(state.r) * feature.aN,
			basis.ay);
		var theta = A2(
			$elm$core$Basics$atan2,
			$author$project$Surface$dot$(direction, feature.aA),
			$author$project$Surface$dot$(direction, feature.az)) + ((outwardSign < 0) ? $elm$core$Basics$pi : 0);
		return $author$project$Surface$insideSweep$(feature, theta) ? $elm$core$Result$Ok(
			{
				r: atStart ? 0 : $elm$core$Basics$pi,
				a: state.a,
				d: $author$project$Surface$clampTheta$(feature, theta)
			}) : $elm$core$Result$Err(direction);
	} else {
		return $elm$core$Result$Ok(state);
	}
};
var $author$project$Surface$leavePole = F2($author$project$Surface$leavePole$);
var $author$project$Surface$maxSeamCrossings = 200;
var $author$project$Surface$nearestExcluding$ = function (excluded, p, pieces) {
	return $elm$core$Maybe$map$(
		$elm$core$Tuple$first,
		$elm$core$Array$foldl$(
			F2(
				function (piece, _v0) {
					var index = _v0.a;
					var best = _v0.b;
					if (_Utils_eq(index, excluded)) {
						return _Utils_Tuple2(index + 1, best);
					} else {
						var _v1 = $author$project$Surface$projectOntoPiece$(piece, p);
						var a = _v1.a;
						var b = _v1.b;
						var distance = $author$project$Surface$lengthOf(
							$author$project$Surface$sub$(
								$author$project$Surface$piecePoint$(piece, a, b),
								p));
						return _Utils_Tuple2(
							index + 1,
							function () {
								if (!best.$) {
									var _v3 = best.a;
									var bestDistance = _v3.b;
									return (_Utils_cmp(distance, bestDistance) < 0) ? $elm$core$Maybe$Just(
										_Utils_Tuple2(
											{cK: a, cM: b, aq: index},
											distance)) : best;
								} else {
									return $elm$core$Maybe$Just(
										_Utils_Tuple2(
											{cK: a, cM: b, aq: index},
											distance));
								}
							}());
					}
				}),
			_Utils_Tuple2(0, $elm$core$Maybe$Nothing),
			pieces).b);
};
var $author$project$Surface$nearestExcluding = F3($author$project$Surface$nearestExcluding$);
var $author$project$Surface$derivative$ = function (feature, state) {
	var p = $author$project$Surface$profileAt$(feature, state.a);
	var r = $author$project$Surface$maxFloat$(1.0e-6, p.f);
	return {
		r: ((-$elm$core$Basics$sin(state.r)) * p.N) / r,
		a: $elm$core$Basics$cos(state.r),
		d: (feature.aN * $elm$core$Basics$sin(state.r)) / r
	};
};
var $author$project$Surface$derivative = F2($author$project$Surface$derivative$);
var $author$project$Surface$rk4$ = function (feature, h, state) {
	var offset = F2(
		function (k, f) {
			return {r: state.r + (f * k.r), a: state.a + (f * k.a), d: state.d + (f * k.d)};
		});
	var k1 = $author$project$Surface$derivative$(feature, state);
	var k2 = $author$project$Surface$derivative$(
		feature,
		A2(offset, k1, h / 2));
	var k3 = $author$project$Surface$derivative$(
		feature,
		A2(offset, k2, h / 2));
	var k4 = $author$project$Surface$derivative$(
		feature,
		A2(offset, k3, h));
	return {r: state.r + ((h / 6) * (((k1.r + (2 * k2.r)) + (2 * k3.r)) + k4.r)), a: state.a + ((h / 6) * (((k1.a + (2 * k2.a)) + (2 * k3.a)) + k4.a)), d: state.d + ((h / 6) * (((k1.d + (2 * k2.d)) + (2 * k3.d)) + k4.d))};
};
var $author$project$Surface$rk4 = F3($author$project$Surface$rk4$);
var $author$project$Surface$refineFraction$ = function (feature, edgeIndex, h, state, fraction, iterations) {
	refineFraction:
	while (true) {
		if (iterations <= 0) {
			return fraction;
		} else {
			var partial = $author$project$Surface$rk4$(feature, h * fraction, state);
			var rate = $author$project$Surface$derivative$(feature, partial);
			var _v0 = function () {
				switch (edgeIndex) {
					case 0:
						return _Utils_Tuple2(partial.a, rate.a);
					case 1:
						return _Utils_Tuple2(partial.a - feature.aR, rate.a);
					case 2:
						return _Utils_Tuple2(
							partial.d - $author$project$Surface$sweepStart(feature),
							rate.d);
					default:
						return _Utils_Tuple2(
							partial.d - $author$project$Surface$sweepRange(feature).b,
							rate.d);
				}
			}();
			var value = _v0.a;
			var speed = _v0.b;
			if ($elm$core$Basics$abs(speed * h) < 1.0e-12) {
				return fraction;
			} else {
				var $temp$fraction = $author$project$Surface$clampFloat$(0, 1, fraction - (value / (speed * h))),
					$temp$iterations = iterations - 1;
				fraction = $temp$fraction;
				iterations = $temp$iterations;
				continue refineFraction;
			}
		}
	}
};
var $author$project$Surface$refineFraction = F6($author$project$Surface$refineFraction$);
var $author$project$Surface$sampleAt$ = function (piece, pieceIndex, a, b) {
	return {
		K: $author$project$Surface$mapChart$(piece, a, b),
		aq: pieceIndex,
		gQ: $author$project$Surface$piecePoint$(piece, a, b)
	};
};
var $author$project$Surface$sampleAt = F4($author$project$Surface$sampleAt$);
var $author$project$Surface$crossTrace$ = function (context, crossings, pieceIndex, edgeIndex, edgePoint, travelled, index, trace) {
	var _v31 = _Utils_Tuple2(
		$elm$core$Array$get$(pieceIndex, context.A),
		$elm$core$Maybe$andThen$(
			$elm$core$Basics$identity,
			$elm$core$Maybe$andThen$(
				$elm$core$Array$get(edgeIndex),
				$elm$core$Array$get$(pieceIndex, context.a8))));
	if ((!_v31.a.$) && (!_v31.b.$)) {
		var piece = _v31.a.a;
		var _v32 = _v31.b.a;
		var otherIndex = _v32.a;
		var otherEdge = _v32.b;
		var _v33 = $elm$core$Array$get$(otherIndex, context.A);
		if (!_v33.$) {
			var other = _v33.a;
			return $author$project$Surface$traceStep$(
				context,
				crossings + 1,
				$author$project$Surface$crossSeam$(piece, edgeIndex, edgePoint, other, otherIndex, otherEdge),
				travelled,
				index,
				trace);
		} else {
			return trace;
		}
	} else {
		return trace;
	}
};
var $author$project$Surface$crossTrace = F8($author$project$Surface$crossTrace$);
var $author$project$Surface$traceCylinder$ = function (context, crossings, pieceIndex, piece, feature, radius, state, travelled, index, trace) {
	var ds = $elm$core$Basics$cos(state.r);
	var dTheta = (feature.aN * $elm$core$Basics$sin(state.r)) / radius;
	var exits = $elm$core$List$head(
		A2(
			$elm$core$List$sortBy,
			$elm$core$Tuple$second,
			$elm$core$List$filterMap$(
				$elm$core$Basics$identity,
				_Utils_ap(
					_List_fromArray(
						[
							((ds + 1.0e-12) < 0) ? $elm$core$Maybe$Just(
							_Utils_Tuple2(0, (-state.a) / ds)) : $elm$core$Maybe$Nothing,
							(ds > 1.0e-12) ? $elm$core$Maybe$Just(
							_Utils_Tuple2(1, (feature.aR - state.a) / ds)) : $elm$core$Maybe$Nothing
						]),
					function () {
						var _v30 = feature.jg;
						if (!_v30.$) {
							var to = _v30.a.e;
							var from = _v30.a.c;
							return _List_fromArray(
								[
									((dTheta + 1.0e-12) < 0) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(2, (from - state.d) / dTheta)) : $elm$core$Maybe$Nothing,
									(dTheta > 1.0e-12) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(3, (to - state.d) / dTheta)) : $elm$core$Maybe$Nothing
								]);
						} else {
							return _List_Nil;
						}
					}()))));
	var until = $author$project$Surface$minFloat$(
		context.aZ * $author$project$Surface$fanSpacing,
		function () {
			if (!exits.$) {
				var _v29 = exits.a;
				var t = _v29.b;
				return travelled + $author$project$Surface$maxFloat$(0, t);
			} else {
				return 1 / 0;
			}
		}());
	var _v23 = $author$project$Surface$emitSamples$(
		context,
		travelled,
		until,
		function (t) {
			return $author$project$Surface$sampleAt$(piece, pieceIndex, state.d + (t * dTheta), state.a + (t * ds));
		},
		index,
		trace.iX);
	var nextIndex = _v23.a;
	var samples = _v23.b;
	if (!exits.$) {
		var _v25 = exits.a;
		var edgeIndex = _v25.a;
		var t_ = _v25.b;
		var t = $author$project$Surface$maxFloat$(0, t_);
		var _v26 = function () {
			switch (edgeIndex) {
				case 0:
					return _Utils_Tuple2(state.d + (t * dTheta), 0);
				case 1:
					return _Utils_Tuple2(state.d + (t * dTheta), feature.aR);
				case 2:
					return _Utils_Tuple2(
						$author$project$Surface$sweepStart(feature),
						state.a + (t * ds));
				default:
					return _Utils_Tuple2(
						$author$project$Surface$sweepRange(feature).b,
						state.a + (t * ds));
			}
		}();
		var a = _v26.a;
		var b = _v26.b;
		return $author$project$Surface$crossTrace$(
			context,
			crossings,
			pieceIndex,
			edgeIndex,
			{cK: a, cM: b, i: state.r, aq: pieceIndex},
			travelled + t,
			nextIndex,
			_Utils_update(
				trace,
				{iX: samples}));
	} else {
		return _Utils_update(
			trace,
			{iX: samples});
	}
};
var $author$project$Surface$traceCylinder = function (context) {
	return function (crossings) {
		return function (pieceIndex) {
			return function (piece) {
				return function (feature) {
					return function (radius) {
						return function (state) {
							return function (travelled) {
								return function (index) {
									return function (trace) {
										return $author$project$Surface$traceCylinder$(context, crossings, pieceIndex, piece, feature, radius, state, travelled, index, trace);
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Surface$traceFeature$ = function (context, crossings, pieceIndex, piece, feature, state_, travelled, index, trace) {
	traceFeature:
	while (true) {
		if ((index - context.aZ) > 0) {
			return trace;
		} else {
			var _v16 = $author$project$Surface$leavePole$(feature, state_);
			if (_v16.$ === 1) {
				var direction = _v16.a;
				var _v17 = $author$project$Surface$nearestExcluding$(
					pieceIndex,
					$author$project$Surface$add$(
						$author$project$Surface$featurePoint$(feature, state_.d, state_.a),
						$author$project$Surface$scale$(1.0e-7, direction)),
					context.A);
				if (!_v17.$) {
					var next = _v17.a;
					var _v18 = $elm$core$Array$get$(next.aq, context.A);
					if (!_v18.$) {
						var nextPiece = _v18.a;
						return $author$project$Surface$traceStep$(
							context,
							crossings + 1,
							{
								cK: next.cK,
								cM: next.cM,
								i: $author$project$Surface$vecToHeading$(
									$author$project$Surface$tangentFrame$(nextPiece, next.cK, next.cM),
									direction),
								aq: next.aq
							},
							travelled,
							index,
							trace);
					} else {
						return trace;
					}
				} else {
					return trace;
				}
			} else {
				var state = _v16.a;
				var target = index * $author$project$Surface$fanSpacing;
				if ((target - travelled) <= 1.0e-9) {
					var $temp$state_ = state,
						$temp$index = index + 1,
						$temp$trace = _Utils_update(
						trace,
						{
							iX: A2(
								$elm$core$List$cons,
								$author$project$Surface$sampleAt$(piece, pieceIndex, state.d, state.a),
								trace.iX)
						});
					state_ = $temp$state_;
					index = $temp$index;
					trace = $temp$trace;
					continue traceFeature;
				} else {
					var h = $author$project$Surface$minFloat$(
						target - travelled,
						$author$project$Surface$maxFloat$(
							1.0e-4,
							0.25 * $author$project$Surface$profileAt$(feature, state.a).f));
					var next = $author$project$Surface$rk4$(feature, h, state);
					var _v19 = $author$project$Surface$firstViolation$(feature, state, next);
					if (!_v19.$) {
						var _v20 = _v19.a;
						var edgeIndex = _v20.a;
						var roughFraction = _v20.b;
						var fraction = $author$project$Surface$refineFraction$(feature, edgeIndex, h, state, roughFraction, 3);
						var partial = $author$project$Surface$rk4$(feature, h * fraction, state);
						var clamped = function () {
							switch (edgeIndex) {
								case 0:
									return _Utils_update(
										partial,
										{a: 0});
								case 1:
									return _Utils_update(
										partial,
										{a: feature.aR});
								case 2:
									return _Utils_update(
										partial,
										{
											d: $author$project$Surface$sweepStart(feature)
										});
								default:
									return _Utils_update(
										partial,
										{
											d: $author$project$Surface$sweepRange(feature).b
										});
							}
						}();
						if ((edgeIndex <= 1) && (($elm$core$Basics$abs(
							$author$project$Surface$profileAt$(feature, clamped.a).f) - $author$project$Surface$tolerance) < 0)) {
							var $temp$state_ = clamped,
								$temp$travelled = travelled + (h * fraction);
							state_ = $temp$state_;
							travelled = $temp$travelled;
							continue traceFeature;
						} else {
							return $author$project$Surface$crossTrace$(
								context,
								crossings,
								pieceIndex,
								edgeIndex,
								{cK: clamped.d, cM: clamped.a, i: clamped.r, aq: pieceIndex},
								travelled + (h * fraction),
								index,
								trace);
						}
					} else {
						var $temp$state_ = function () {
							var _v22 = feature.jg;
							if (!_v22.$) {
								return next;
							} else {
								return _Utils_update(
									next,
									{
										d: $author$project$Surface$wrapAngle(next.d)
									});
							}
						}(),
							$temp$travelled = travelled + h;
						state_ = $temp$state_;
						travelled = $temp$travelled;
						continue traceFeature;
					}
				}
			}
		}
	}
};
var $author$project$Surface$traceFeature = F9($author$project$Surface$traceFeature$);
var $author$project$Surface$traceSphere$ = function (context, crossings, pieceIndex, piece, feature, center, radius, state, travelled, index, trace) {
	var offset = $author$project$Surface$sub$(center, feature.z);
	var basis = $author$project$Surface$featureBasis$(feature, state.d, state.a);
	var e1 = $author$project$Surface$scale$(
		1 / radius,
		$author$project$Surface$sub$(basis.L, center));
	var e2 = $author$project$Surface$combine$(
		$elm$core$Basics$cos(state.r),
		basis.ax,
		$elm$core$Basics$sin(state.r) * feature.aN,
		basis.ay);
	var crossing = F2(
		function (n, k) {
			var k_ = k - $author$project$Surface$dot$(offset, n);
			var cb = radius * $author$project$Surface$dot$(e2, n);
			var ca = radius * $author$project$Surface$dot$(e1, n);
			var m = $elm$core$Basics$sqrt((ca * ca) + (cb * cb));
			if ((m < 1.0e-12) || (_Utils_cmp(
				$elm$core$Basics$abs(k_),
				m) > -1)) {
				return $elm$core$Maybe$Nothing;
			} else {
				var spread_ = $elm$core$Basics$acos(k_ / m);
				var firstPositive = function (angle) {
					return $author$project$Surface$wrapAngle(angle - 1.0e-6) + 1.0e-6;
				};
				var delta = A2($elm$core$Basics$atan2, cb, ca);
				return $elm$core$Maybe$Just(
					$author$project$Surface$minFloat$(
						firstPositive(delta - spread_),
						firstPositive(delta + spread_)));
			}
		});
	var profileEdge = F2(
		function (edgeIndex, s) {
			var end = $author$project$Surface$profileAt$(feature, s);
			return (_Utils_cmp(
				$elm$core$Basics$abs(end.f),
				$author$project$Surface$tolerance) < 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$map$(
				function (angle) {
					return _Utils_Tuple2(edgeIndex, angle);
				},
				A2(crossing, feature.an, end.bz));
		});
	var sweepEdge = F2(
		function (edgeIndex, theta) {
			return $elm$core$Maybe$map$(
				function (angle) {
					return _Utils_Tuple2(edgeIndex, angle);
				},
				A2(
					crossing,
					$author$project$Surface$combine$(
						-$elm$core$Basics$sin(theta),
						feature.az,
						$elm$core$Basics$cos(theta),
						feature.aA),
					0));
		});
	var exit = $elm$core$List$head(
		A2(
			$elm$core$List$sortBy,
			$elm$core$Tuple$second,
			$elm$core$List$filterMap$(
				$elm$core$Basics$identity,
				_Utils_ap(
					_List_fromArray(
						[
							A2(profileEdge, 0, 0),
							A2(profileEdge, 1, feature.aR)
						]),
					function () {
						var _v15 = feature.jg;
						if (!_v15.$) {
							var to = _v15.a.e;
							var from = _v15.a.c;
							return _List_fromArray(
								[
									A2(sweepEdge, 2, from),
									A2(sweepEdge, 3, to)
								]);
						} else {
							return _List_Nil;
						}
					}()))));
	var until = $author$project$Surface$minFloat$(
		context.aZ * $author$project$Surface$fanSpacing,
		function () {
			if (!exit.$) {
				var _v14 = exit.a;
				var angle = _v14.b;
				return travelled + (radius * angle);
			} else {
				return 1 / 0;
			}
		}());
	var at = function (angle) {
		return $author$project$Surface$add$(
			center,
			$author$project$Surface$combine$(
				radius * $elm$core$Basics$cos(angle),
				e1,
				radius * $elm$core$Basics$sin(angle),
				e2));
	};
	var _v8 = $author$project$Surface$emitSamples$(
		context,
		travelled,
		until,
		function (t) {
			var position = at(t / radius);
			var local = $author$project$Surface$localCoordinatesUnclamped$(piece, position);
			return {
				K: $author$project$Surface$mapChart$(piece, local.cK, local.cM),
				aq: pieceIndex,
				gQ: position
			};
		},
		index,
		trace.iX);
	var nextIndex = _v8.a;
	var samples = _v8.b;
	if (!exit.$) {
		var _v10 = exit.a;
		var edgeIndex = _v10.a;
		var angle = _v10.b;
		var local = $author$project$Surface$localCoordinatesUnclamped$(
			piece,
			at(angle));
		var _v11 = function () {
			switch (edgeIndex) {
				case 0:
					return _Utils_Tuple2(
						$author$project$Surface$clampTheta$(feature, local.cK),
						0);
				case 1:
					return _Utils_Tuple2(
						$author$project$Surface$clampTheta$(feature, local.cK),
						feature.aR);
				case 2:
					return _Utils_Tuple2(
						$author$project$Surface$sweepStart(feature),
						$elm$core$Basics$clamp$(0, feature.aR, local.cM));
				default:
					return _Utils_Tuple2(
						$author$project$Surface$sweepRange(feature).b,
						$elm$core$Basics$clamp$(0, feature.aR, local.cM));
			}
		}();
		var a = _v11.a;
		var b = _v11.b;
		return $author$project$Surface$crossTrace$(
			context,
			crossings,
			pieceIndex,
			edgeIndex,
			{
				cK: a,
				cM: b,
				i: $author$project$Surface$vecToHeading$(
					$author$project$Surface$tangentFrame$(piece, a, b),
					$author$project$Surface$combine$(
						-$elm$core$Basics$sin(angle),
						e1,
						$elm$core$Basics$cos(angle),
						e2)),
				aq: pieceIndex
			},
			travelled + (radius * angle),
			nextIndex,
			_Utils_update(
				trace,
				{iX: samples}));
	} else {
		return _Utils_update(
			trace,
			{iX: samples});
	}
};
var $author$project$Surface$traceSphere = function (context) {
	return function (crossings) {
		return function (pieceIndex) {
			return function (piece) {
				return function (feature) {
					return function (center) {
						return function (radius) {
							return function (state) {
								return function (travelled) {
									return function (index) {
										return function (trace) {
											return $author$project$Surface$traceSphere$(context, crossings, pieceIndex, piece, feature, center, radius, state, travelled, index, trace);
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Surface$traceStep$ = function (context, crossings, point, travelled, index, trace) {
	if (((index - context.aZ) > 0) || ((crossings - $author$project$Surface$maxSeamCrossings) > 0)) {
		return trace;
	} else {
		var _v0 = $elm$core$Array$get$(point.aq, context.A);
		if (!_v0.$) {
			var piece = _v0.a;
			var newTrace = (((travelled - trace.a$) < 0) && (!_Utils_eq(
				$elm$core$Array$get$(point.aq, context.dn),
				$elm$core$Maybe$Just(true)))) ? _Utils_update(
				trace,
				{a$: travelled}) : trace;
			if (!piece.$) {
				var flat = piece.a;
				var dy = $elm$core$Basics$sin(point.i);
				var dx = $elm$core$Basics$cos(point.i);
				var exit = $author$project$Surface$flatExit$(flat, point.cK, point.cM, dx, dy);
				var until = $author$project$Surface$minFloat$(
					context.aZ * $author$project$Surface$fanSpacing,
					function () {
						if (!exit.$) {
							var _v6 = exit.a;
							var t = _v6.b;
							return travelled + t;
						} else {
							return 1 / 0;
						}
					}());
				var emit = F2(
					function (i, samples) {
						emit:
						while (true) {
							var t = (i * $author$project$Surface$fanSpacing) - travelled;
							if (((i * $author$project$Surface$fanSpacing) - until) <= 1.0e-9) {
								var $temp$i = i + 1,
									$temp$samples = A2(
									$elm$core$List$cons,
									$author$project$Surface$sampleAt$(piece, point.aq, point.cK + (t * dx), point.cM + (t * dy)),
									samples);
								i = $temp$i;
								samples = $temp$samples;
								continue emit;
							} else {
								return _Utils_Tuple2(i, samples);
							}
						}
					});
				var _v2 = A2(emit, index, newTrace.iX);
				var nextIndex = _v2.a;
				var samples_ = _v2.b;
				if (!exit.$) {
					var _v4 = exit.a;
					var edgeIndex = _v4.a;
					var t = _v4.b;
					return $author$project$Surface$crossTrace$(
						context,
						crossings,
						point.aq,
						edgeIndex,
						_Utils_update(
							point,
							{cK: point.cK + (t * dx), cM: point.cM + (t * dy)}),
						travelled + t,
						nextIndex,
						_Utils_update(
							newTrace,
							{iX: samples_}));
				} else {
					return _Utils_update(
						newTrace,
						{iX: samples_});
				}
			} else {
				var feature = piece.a;
				var state = {r: point.i, a: point.cM, d: point.cK};
				var _v7 = $author$project$Surface$featureShape(feature);
				switch (_v7.$) {
					case 0:
						var radius = _v7.a;
						return $author$project$Surface$traceCylinder$(context, crossings, point.aq, piece, feature, radius, state, travelled, index, newTrace);
					case 1:
						var center = _v7.a;
						var radius = _v7.b;
						return (($author$project$Surface$profileAt$(feature, state.a).f - $author$project$Surface$tolerance) < 0) ? $author$project$Surface$traceFeature$(context, crossings, point.aq, piece, feature, state, travelled, index, newTrace) : $author$project$Surface$traceSphere$(context, crossings, point.aq, piece, feature, center, radius, state, travelled, index, newTrace);
					default:
						return $author$project$Surface$traceFeature$(context, crossings, point.aq, piece, feature, state, travelled, index, newTrace);
				}
			}
		} else {
			return trace;
		}
	}
};
var $author$project$Surface$traceStep = F6($author$project$Surface$traceStep$);
var $author$project$Surface$traceFan$ = function (context, walker, windows) {
	var traceAt = function (angle) {
		var trace = $author$project$Surface$traceStep$(
			context,
			0,
			_Utils_update(
				walker,
				{i: (walker.i + angle) - ($elm$core$Basics$pi / 2)}),
			0,
			0,
			{a$: 1 / 0, iX: _List_Nil});
		return {
			fS: angle,
			a$: trace.a$,
			iX: $elm$core$List$reverse(trace.iX)
		};
	};
	var refine = F3(
		function (depth, left, right) {
			if ((depth > 0) && (_Utils_cmp(
				$author$project$Surface$spread$(left.iX, right.iX),
				$author$project$Surface$fanGap) > 0)) {
				var middle = traceAt((left.fS + right.fS) / 2);
				return _Utils_ap(
					A3(refine, depth - 1, left, middle),
					A3(refine, depth - 1, middle, right));
			} else {
				return _List_fromArray(
					[right]);
			}
		});
	var traceGroup = function (_v1) {
		var from = _v1.a;
		var to = _v1.b;
		var steps = $elm$core$Basics$max$(
			2,
			$elm$core$Basics$ceiling((to - from) / $author$project$Surface$fanAngle));
		var rays = $elm$core$List$map$(
			function (i) {
				return traceAt(from + (((to - from) * i) / steps));
			},
			$elm$core$List$range$(0, steps));
		if (rays.b) {
			var first = rays.a;
			var others = rays.b;
			return $author$project$Surface$finishGroup(
				A2(
					$elm$core$List$cons,
					first,
					$elm$core$List$concat(
						A3(
							$elm$core$List$map2,
							refine($author$project$Surface$maxFanRefinement),
							rays,
							others))));
		} else {
			return _List_Nil;
		}
	};
	return $elm$core$List$map$(
		traceGroup,
		$author$project$Surface$mergeWindows(windows));
};
var $author$project$Surface$traceFan = F3($author$project$Surface$traceFan$);
var $author$project$Surface$mapAround$ = function (radius, _v0, _v1) {
	var walker = _v0;
	var seams = _v1.a8;
	var pieces = _v1.A;
	var _v2 = $elm$core$Array$get$(walker.aq, pieces);
	if (!_v2.$) {
		var piece = _v2.a;
		var _v3 = function () {
			if ($author$project$Surface$isRigid(piece)) {
				var rho = function () {
					if (!piece.$) {
						return 1;
					} else {
						var feature = piece.a;
						return $author$project$Surface$profileAt$(feature, walker.cM).f;
					}
				}();
				var scale_ = $author$project$Surface$cmul$(
					{ad: rho, aj: 0},
					{
						ad: -$elm$core$Basics$sin(walker.i),
						aj: $elm$core$Basics$cos(walker.i)
					});
				var chart = $author$project$Surface$localChart$(piece, walker.cK, walker.cM);
				var start = {
					bO: 0,
					h3: $author$project$Surface$holeOnMap$(
						piece,
						{
							gG: $author$project$Surface$cscale$(
								-1,
								$author$project$Surface$cmul$(scale_, chart)),
							aG: scale_
						}),
					gG: $author$project$Surface$cscale$(
						-1,
						$author$project$Surface$cmul$(scale_, chart)),
					aq: walker.aq,
					aG: scale_,
					fM: $author$project$Surface$fullWindow
				};
				return $author$project$Surface$flattenHelper$(
					radius,
					pieces,
					seams,
					_List_fromArray(
						[
							{
							e1: -1,
							H: start,
							fr: _List_fromArray(
								[walker.aq])
						}
						]),
					_List_fromArray(
						[start]),
					_List_Nil);
			} else {
				return _Utils_Tuple2(
					_List_Nil,
					_List_fromArray(
						[$author$project$Surface$fullWindow]));
			}
		}();
		var placements = _v3.a;
		var curved = _v3.b;
		return {
			hW: $author$project$Surface$traceFan$(
				{
					aZ: $elm$core$Basics$ceiling(radius / $author$project$Surface$fanSpacing),
					A: pieces,
					dn: $elm$core$Array$map$($author$project$Surface$isRigid, pieces),
					a8: seams
				},
				walker,
				curved),
			iN: placements
		};
	} else {
		return {hW: _List_Nil, iN: _List_Nil};
	}
};
var $author$project$Surface$mapAround = F3($author$project$Surface$mapAround$);
var $author$project$Minimap$angleBetween$ = function (a, b) {
	var d = (a - b) + $elm$core$Basics$pi;
	return (d - ((2 * $elm$core$Basics$pi) * $elm$core$Basics$floor(d / (2 * $elm$core$Basics$pi)))) - $elm$core$Basics$pi;
};
var $author$project$Minimap$angleBetween = F2($author$project$Minimap$angleBetween$);
var $author$project$Minimap$placementImage$ = function (radius, point, placement) {
	if (!_Utils_eq(placement.aq, point.aq)) {
		return $elm$core$Maybe$Nothing;
	} else {
		var w = $author$project$Surface$placeOnMap$(placement, point.K);
		var lengthSquared = (w.aj * w.aj) + (w.ad * w.ad);
		var inWindow = (_Utils_cmp(placement.fM.f5, $elm$core$Basics$pi) > -1) || (_Utils_cmp(
			$elm$core$Basics$abs(
				$author$project$Minimap$angleBetween$(
					A2($elm$core$Basics$atan2, w.ad, w.aj),
					placement.fM.b)),
			placement.fM.f5 + 0.002) < 1);
		var behindHole = function () {
			var _v0 = placement.h3;
			if (!_v0.$) {
				var hole = _v0.a;
				var t = (lengthSquared > 0) ? $elm$core$Basics$clamp$(0, 1, ((hole.b.aj * w.aj) + (hole.b.ad * w.ad)) / lengthSquared) : 0;
				return _Utils_cmp(
					A2($elm$core$Basics$pow, (t * w.aj) - hole.b.aj, 2) + A2($elm$core$Basics$pow, (t * w.ad) - hole.b.ad, 2),
					hole.p * hole.p) < 0;
			} else {
				return false;
			}
		}();
		return (inWindow && ((!behindHole) && (_Utils_cmp(
			lengthSquared,
			A2($elm$core$Basics$pow, 1.2 * radius, 2)) < 0))) ? $elm$core$Maybe$Just(
			{m: w.aj, n: w.ad}) : $elm$core$Maybe$Nothing;
	}
};
var $author$project$Minimap$placementImage = F3($author$project$Minimap$placementImage$);
var $ianmackenzie$elm_units$Length$meters = function (numMeters) {
	return numMeters;
};
var $author$project$Minimap$viewRadius = $ianmackenzie$elm_units$Length$meters(4);
var $author$project$Surface$withFrame$ = function (func, _v0, surface) {
	var point = _v0;
	return $elm$core$Maybe$map$(
		function (piece) {
			return func(
				$author$project$Surface$tangentFrame$(piece, point.cK, point.cM));
		},
		$author$project$Surface$getPiece$(point.aq, surface));
};
var $author$project$Surface$withFrame = F3($author$project$Surface$withFrame$);
var $author$project$Surface$worldPosition = $author$project$Surface$withFrame(
	A2(
		$elm$core$Basics$composeR,
		function ($) {
			return $.L;
		},
		$author$project$Surface$toPoint));
var $author$project$Minimap$imagesAround$ = function (surface, shapes, surfacePoint) {
	var radius = $ianmackenzie$elm_units$Length$inMeters($author$project$Minimap$viewRadius);
	var layout = $author$project$Surface$mapAround$(radius, surfacePoint, surface);
	var _v0 = A2($author$project$Surface$worldPosition, surfacePoint, surface);
	if (!_v0.$) {
		var position = _v0.a;
		var player = $ianmackenzie$elm_geometry$Point3d$toMeters(position);
		var throughPlacements = $elm$core$Array$map$(
			function (point) {
				return (($author$project$Minimap$distance$(point.gQ, player) - (radius + 0.05)) <= 0) ? $elm$core$List$foldl$(
					$author$project$Minimap$addImage,
					_List_Nil,
					$elm$core$List$filterMap$(
						A2($author$project$Minimap$placementImage, radius, point),
						layout.iN)) : _List_Nil;
			},
			shapes.fn);
		return $elm$core$List$foldl$(
			$author$project$Minimap$addFanImages(shapes),
			throughPlacements,
			$author$project$Minimap$fanTriangles(layout.hW));
	} else {
		return $elm$core$Array$empty;
	}
};
var $author$project$Minimap$imagesAround = F3($author$project$Minimap$imagesAround$);
var $ianmackenzie$elm_units$Pixels$inPixels = function (_v0) {
	var numPixels = _v0;
	return numPixels;
};
var $elm$core$Maybe$map3$ = function (func, ma, mb, mc) {
	if (ma.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var a = ma.a;
		if (mb.$ === 1) {
			return $elm$core$Maybe$Nothing;
		} else {
			var b = mb.a;
			if (mc.$ === 1) {
				return $elm$core$Maybe$Nothing;
			} else {
				var c = mc.a;
				return $elm$core$Maybe$Just(
					A3(func, a, b, c));
			}
		}
	}
};
var $elm$core$Maybe$map3 = F4($elm$core$Maybe$map3$);
var $author$project$Minimap$maxStretch = 4;
var $author$project$Minimap$closestMatch$ = function (surfaceDistance, image, candidates) {
	var reach = ($author$project$Minimap$maxStretch * surfaceDistance) + $author$project$Minimap$sameImage;
	return $elm$core$Maybe$map$(
		$elm$core$Tuple$second,
		$elm$core$List$foldl$(
			F2(
				function (candidate, best) {
					var d = $author$project$Minimap$mapDistance$(image, candidate);
					if (!best.$) {
						var _v1 = best.a;
						var bestDistance = _v1.a;
						return ((d - bestDistance) < 0) ? $elm$core$Maybe$Just(
							_Utils_Tuple2(d, candidate)) : best;
					} else {
						return ((d - reach) <= 0) ? $elm$core$Maybe$Just(
							_Utils_Tuple2(d, candidate)) : $elm$core$Maybe$Nothing;
					}
				}),
			$elm$core$Maybe$Nothing,
			candidates));
};
var $author$project$Minimap$closestMatch = F3($author$project$Minimap$closestMatch$);
var $author$project$Minimap$pavingTriangles$ = function (_v0, _v1, _v2) {
	var p = _v0.a;
	var pImages = _v0.b;
	var q = _v1.a;
	var qImages = _v1.b;
	var r = _v2.a;
	var rImages = _v2.b;
	return $elm$core$List$filterMap$(
		function (a) {
			var _v3 = _Utils_Tuple2(
				$author$project$Minimap$closestMatch$(
					$author$project$Minimap$distance$(p.gQ, q.gQ),
					a,
					qImages),
				$author$project$Minimap$closestMatch$(
					$author$project$Minimap$distance$(p.gQ, r.gQ),
					a,
					rImages));
			if ((!_v3.a.$) && (!_v3.b.$)) {
				var b = _v3.a.a;
				var c = _v3.b.a;
				return (($author$project$Minimap$mapDistance$(b, c) - (($author$project$Minimap$maxStretch * $author$project$Minimap$distance$(q.gQ, r.gQ)) + $author$project$Minimap$sameImage)) <= 0) ? $elm$core$Maybe$Just(
					_Utils_Tuple3(a, b, c)) : $elm$core$Maybe$Nothing;
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		pImages);
};
var $author$project$Minimap$pavingTriangles = F3($author$project$Minimap$pavingTriangles$);
var $ianmackenzie$elm_units$Pixels$pixels = function (numPixels) {
	return numPixels;
};
var $author$project$Minimap$size = $ianmackenzie$elm_units$Pixels$pixels(500);
var $author$project$Minimap$quad$ = function (width, a, b) {
	var length = $author$project$Minimap$maxFloat$(
		1.0e-9,
		$author$project$Minimap$mapDistance$(a, b));
	var ux = (((b.m - a.m) / length) * width) / 2;
	var uy = (((b.n - a.n) / length) * width) / 2;
	var corner = F3(
		function (s, t, p) {
			return {m: (p.m + (s * ux)) - (t * uy), n: (p.n + (s * uy)) + (t * ux)};
		});
	var b2 = A3(corner, 1, -1, b);
	var b1 = A3(corner, 1, 1, b);
	var a2 = A3(corner, -1, -1, a);
	var a1 = A3(corner, -1, 1, a);
	return _List_fromArray(
		[
			_Utils_Tuple3(a1, a2, b2),
			_Utils_Tuple3(a1, b2, b1)
		]);
};
var $author$project$Minimap$quad = F3($author$project$Minimap$quad$);
var $author$project$Minimap$wallQuads$ = function (width, points) {
	if (points.b && points.b.b) {
		var _v1 = points.a;
		var p = _v1.a;
		var pImages = _v1.b;
		var rest = points.b;
		var _v2 = rest.a;
		var q = _v2.a;
		var qImages = _v2.b;
		return _Utils_ap(
			$elm$core$List$concatMap$(
				function (a) {
					var _v3 = $author$project$Minimap$closestMatch$(
						$author$project$Minimap$distance$(p.gQ, q.gQ),
						a,
						qImages);
					if (!_v3.$) {
						var b = _v3.a;
						return $author$project$Minimap$quad$(width, a, b);
					} else {
						return _List_Nil;
					}
				},
				pImages),
			$author$project$Minimap$wallQuads$(width, rest));
	} else {
		return _List_Nil;
	}
};
var $author$project$Minimap$wallQuads = F2($author$project$Minimap$wallQuads$);
var $author$project$Minimap$wallWidth = 2.5;
var $author$project$Minimap$drawingAround$ = function (surface, shapes, surfacePoint) {
	var sizeInPixels = $ianmackenzie$elm_units$Pixels$inPixels($author$project$Minimap$size);
	var radius = $ianmackenzie$elm_units$Length$inMeters($author$project$Minimap$viewRadius);
	var images = $author$project$Minimap$imagesAround$(surface, shapes, surfacePoint);
	var withImages = function (index) {
		return $elm$core$Maybe$map2$(
			$elm$core$Tuple$pair,
			$elm$core$Array$get$(index, shapes.fn),
			$elm$core$Array$get$(index, images));
	};
	return {
		bm: $elm$core$List$concatMap$(
			function (_v0) {
				var i = _v0.a;
				var j = _v0.b;
				var k = _v0.c;
				return $elm$core$Maybe$withDefault$(
					_List_Nil,
					$elm$core$Maybe$map3$(
						$author$project$Minimap$pavingTriangles,
						withImages(i),
						withImages(j),
						withImages(k)));
			},
			shapes.iM),
		jE: $elm$core$List$concatMap$(
			function (wall) {
				return $author$project$Minimap$wallQuads$(
					(($author$project$Minimap$wallWidth / sizeInPixels) * 2) * radius,
					$elm$core$List$filterMap$(withImages, wall));
			},
			shapes.jE)
	};
};
var $author$project$Minimap$drawingAround = F3($author$project$Minimap$drawingAround$);
var $author$project$GridLevel$fadd$ = function (a, b) {
	return {m: a.m + b.m, n: a.n + b.n, o: a.o + b.o};
};
var $author$project$GridLevel$fadd = F2($author$project$GridLevel$fadd$);
var $author$project$GridLevel$fscale$ = function (k, a) {
	return {m: k * a.m, n: k * a.n, o: k * a.o};
};
var $author$project$GridLevel$fscale = F2($author$project$GridLevel$fscale$);
var $author$project$GridLevel$toVec = function (v) {
	return {m: v.m, n: v.n, o: v.o};
};
var $author$project$GridLevel$arcPoint$ = function (arc, angle) {
	return $author$project$GridLevel$fadd$(
		$author$project$GridLevel$toVec(arc.b),
		$author$project$GridLevel$fscale$(
			arc.p,
			$author$project$GridLevel$fadd$(
				$author$project$GridLevel$fscale$(
					$elm$core$Basics$cos(angle),
					$author$project$GridLevel$toVec(arc.c)),
				$author$project$GridLevel$fscale$(
					$elm$core$Basics$sin(angle),
					$author$project$GridLevel$toVec(arc.e)))));
};
var $author$project$GridLevel$arcPoint = F2($author$project$GridLevel$arcPoint$);
var $author$project$GridLevel$cellSize = 0.2;
var $author$project$GridLevel$fdot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$GridLevel$fdot = F2($author$project$GridLevel$fdot$);
var $author$project$GridLevel$fsub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$GridLevel$fsub = F2($author$project$GridLevel$fsub$);
var $author$project$GridLevel$edgeSamples = function (edge) {
	var steps = function () {
		var _v3 = edge.t;
		if (!_v3.$) {
			return 1;
		} else {
			var arc = _v3.a;
			return (4 * arc.p) + 4;
		}
	}();
	var across = F3(
		function (value, point, center) {
			if (!value.$) {
				var v = value.a;
				return $author$project$GridLevel$toVec(v);
			} else {
				var s = value.a;
				var d = $author$project$GridLevel$fsub$(point, center);
				var l = $elm$core$Basics$sqrt(
					$author$project$GridLevel$fdot$(d, d));
				return (l < 1.0e-9) ? {m: 0, n: 0, o: 0} : $author$project$GridLevel$fscale$(s / l, d);
			}
		});
	return $elm$core$List$map$(
		function (i) {
			var t = i / steps;
			var _v0 = function () {
				var _v1 = edge.t;
				if (!_v1.$) {
					var a = _v1.a;
					var b = _v1.b;
					return _Utils_Tuple2(
						$author$project$GridLevel$fadd$(
							$author$project$GridLevel$toVec(a),
							$author$project$GridLevel$fscale$(
								t,
								$author$project$GridLevel$fsub$(
									$author$project$GridLevel$toVec(b),
									$author$project$GridLevel$toVec(a)))),
						$author$project$GridLevel$toVec(a));
				} else {
					var arc = _v1.a;
					return _Utils_Tuple2(
						$author$project$GridLevel$arcPoint$(arc, (t * $elm$core$Basics$pi) / 2),
						$author$project$GridLevel$toVec(arc.b));
				}
			}();
			var point = _v0.a;
			var center = _v0.b;
			return {
				ig: $author$project$GridLevel$fscale$(
					-1,
					A3(across, edge.ai, point, center)),
				k: A3(across, edge.k, point, center),
				gQ: $author$project$GridLevel$fscale$($author$project$GridLevel$cellSize, point)
			};
		},
		$elm$core$List$range$(0, steps));
};
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$list$ = function (func, entries) {
	return _Json_wrap(
		$elm$core$List$foldl$(
			_Json_addEntry(func),
			_Json_emptyArray(0),
			entries));
};
var $elm$json$Json$Encode$list = F2($elm$json$Json$Encode$list$);
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		$elm$core$List$foldl$(
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$core$Basics$round = _Basics_round;
var $author$project$Minimap$encodeDrawing = function (drawing) {
	var millimeters = function (meters) {
		return $elm$core$Basics$round(meters * 1000);
	};
	var encodeTriangles = function (triangles) {
		return $elm$json$Json$Encode$list$(
			$elm$json$Json$Encode$int,
			$elm$core$List$foldr$(
				F2(
					function (_v0, acc) {
						var a = _v0.a;
						var b = _v0.b;
						var c = _v0.c;
						return A2(
							$elm$core$List$cons,
							millimeters(a.m),
							A2(
								$elm$core$List$cons,
								millimeters(a.n),
								A2(
									$elm$core$List$cons,
									millimeters(b.m),
									A2(
										$elm$core$List$cons,
										millimeters(b.n),
										A2(
											$elm$core$List$cons,
											millimeters(c.m),
											A2(
												$elm$core$List$cons,
												millimeters(c.n),
												acc))))));
					}),
				_List_Nil,
				triangles));
	};
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'paving',
				encodeTriangles(drawing.bm)),
				_Utils_Tuple2(
				'walls',
				encodeTriangles(drawing.jE))
			]));
};
var $elm$json$Json$Encode$float = _Json_wrap;
var $author$project$Surface$encodeSurfacePoint = function (_v0) {
	var point = _v0;
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'piece',
				$elm$json$Json$Encode$int(point.aq)),
				_Utils_Tuple2(
				'a',
				$elm$json$Json$Encode$float(point.cK)),
				_Utils_Tuple2(
				'b',
				$elm$json$Json$Encode$float(point.cM)),
				_Utils_Tuple2(
				'heading',
				$elm$json$Json$Encode$float(point.i))
			]));
};
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$MinimapWorker$importDecoder = A3(
	$elm$json$Json$Decode$map2,
	$elm$core$Tuple$pair,
	A2($elm$json$Json$Decode$field, 'step', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'scale', $elm$json$Json$Decode$float));
var $elm$json$Json$Decode$maybe = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder),
				$elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing)
			]));
};
var $author$project$MinimapWorker$minimapDrawn = _Platform_outgoingPort('minimapDrawn', $elm$core$Basics$identity);
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$nullable = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder)
			]));
};
var $author$project$GridLevel$Along = function (a) {
	return {$: 0, a: a};
};
var $author$project$GridLevel$Radial = function (a) {
	return {$: 1, a: a};
};
var $author$project$GridLevel$vcross$ = function (a, b) {
	return {m: (a.n * b.o) - (a.o * b.n), n: (a.o * b.m) - (a.m * b.o), o: (a.m * b.n) - (a.n * b.m)};
};
var $author$project$GridLevel$vcross = F2($author$project$GridLevel$vcross$);
var $author$project$GridLevel$vsub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$GridLevel$vsub = F2($author$project$GridLevel$vsub$);
var $author$project$GridLevel$flatOut$ = function (normal, curve) {
	if (!curve.$) {
		var a = curve.a;
		var b = curve.b;
		return $author$project$GridLevel$Along(
			$author$project$GridLevel$vcross$(
				$author$project$GridLevel$vsub$(b, a),
				normal));
	} else {
		var arc = curve.a;
		return _Utils_eq(
			$author$project$GridLevel$vcross$(arc.c, arc.e),
			normal) ? $author$project$GridLevel$Radial(1) : $author$project$GridLevel$Radial(-1);
	}
};
var $author$project$GridLevel$flatOut = F2($author$project$GridLevel$flatOut$);
var $author$project$GridLevel$vscale$ = function (k, a) {
	return {m: k * a.m, n: k * a.n, o: k * a.o};
};
var $author$project$GridLevel$vscale = F2($author$project$GridLevel$vscale$);
var $author$project$GridLevel$acrossCircle$ = function (revolution, _v0) {
	var r = _v0.a;
	var h = _v0.b;
	return (!h) ? $author$project$GridLevel$Radial(r) : $author$project$GridLevel$Along(
		$author$project$GridLevel$vscale$(h, revolution.w));
};
var $author$project$GridLevel$acrossCircle = F2($author$project$GridLevel$acrossCircle$);
var $author$project$GridLevel$neg2 = function (_v0) {
	var a = _v0.a;
	var b = _v0.b;
	return _Utils_Tuple2(-a, -b);
};
var $author$project$GridLevel$vadd$ = function (a, b) {
	return {m: a.m + b.m, n: a.n + b.n, o: a.o + b.o};
};
var $author$project$GridLevel$vadd = F2($author$project$GridLevel$vadd$);
var $author$project$GridLevel$profileDirection$ = function (revolution, radial, _v0) {
	var r = _v0.a;
	var h = _v0.b;
	return $author$project$GridLevel$vadd$(
		$author$project$GridLevel$vscale$(r, radial),
		$author$project$GridLevel$vscale$(h, revolution.w));
};
var $author$project$GridLevel$profileDirection = F3($author$project$GridLevel$profileDirection$);
var $author$project$GridLevel$profileEnds = function (profile) {
	if (!profile.$) {
		var p = profile.a;
		var q = profile.b;
		return _Utils_Tuple2(p, q);
	} else {
		var to = profile.a.e;
		var from = profile.a.c;
		return _Utils_Tuple2(from, to);
	}
};
var $author$project$GridLevel$profilePoint$ = function (revolution, radial, _v0) {
	var rho = _v0.a;
	var h = _v0.b;
	return $author$project$GridLevel$vadd$(
		revolution.b,
		$author$project$GridLevel$vadd$(
			$author$project$GridLevel$vscale$(h, revolution.w),
			$author$project$GridLevel$vscale$(rho, radial)));
};
var $author$project$GridLevel$profilePoint = F3($author$project$GridLevel$profilePoint$);
var $author$project$GridLevel$sub2$ = function (_v0, _v1) {
	var a = _v0.a;
	var b = _v0.b;
	var c = _v1.a;
	var d = _v1.b;
	return _Utils_Tuple2(a - c, b - d);
};
var $author$project$GridLevel$sub2 = F2($author$project$GridLevel$sub2$);
var $author$project$GridLevel$sign = function (n) {
	return (n > 0) ? 1 : ((n < 0) ? (-1) : 0);
};
var $author$project$GridLevel$unit2 = function (_v0) {
	var a = _v0.a;
	var b = _v0.b;
	return _Utils_Tuple2(
		$author$project$GridLevel$sign(a),
		$author$project$GridLevel$sign(b));
};
var $author$project$GridLevel$profileTangents = function (profile) {
	if (!profile.$) {
		var p = profile.a;
		var q = profile.b;
		return _Utils_Tuple2(
			$author$project$GridLevel$unit2(
				$author$project$GridLevel$sub2$(q, p)),
			$author$project$GridLevel$unit2(
				$author$project$GridLevel$sub2$(q, p)));
	} else {
		var center = profile.a.b;
		var to = profile.a.e;
		var from = profile.a.c;
		return _Utils_Tuple2(
			$author$project$GridLevel$unit2(
				$author$project$GridLevel$sub2$(to, center)),
			$author$project$GridLevel$unit2(
				$author$project$GridLevel$sub2$(center, from)));
	}
};
var $author$project$GridLevel$rightNormal = function (_v0) {
	var r = _v0.a;
	var z = _v0.b;
	return _Utils_Tuple2(z, -r);
};
var $author$project$GridLevel$vneg = $author$project$GridLevel$vscale(-1);
var $author$project$GridLevel$revolutionEdges = function (revolution) {
	var y = $author$project$GridLevel$vcross$(revolution.w, revolution.m);
	var circle = function (_v6) {
		var rho = _v6.a;
		var h = _v6.b;
		return $author$project$GridLevel$Arc(
			{
				b: $author$project$GridLevel$vadd$(
					revolution.b,
					$author$project$GridLevel$vscale$(h, revolution.w)),
				c: revolution.m,
				p: rho,
				e: y
			});
	};
	var _v0 = $author$project$GridLevel$profileTangents(revolution.u);
	var t0 = _v0.a;
	var t1 = _v0.b;
	var side = F2(
		function (radial, out) {
			return {
				t: function () {
					var _v2 = revolution.u;
					if (!_v2.$) {
						var p = _v2.a;
						var q = _v2.b;
						return $author$project$GridLevel$Segment$(
							$author$project$GridLevel$profilePoint$(revolution, radial, p),
							$author$project$GridLevel$profilePoint$(revolution, radial, q));
					} else {
						var center = _v2.a.b;
						var to = _v2.a.e;
						var from = _v2.a.c;
						return $author$project$GridLevel$Arc(
							{
								b: $author$project$GridLevel$profilePoint$(revolution, radial, center),
								c: $author$project$GridLevel$profileDirection$(
									revolution,
									radial,
									$author$project$GridLevel$unit2(
										$author$project$GridLevel$sub2$(from, center))),
								p: $elm$core$Basics$abs(
									$author$project$GridLevel$sub2$(from, center).a) + $elm$core$Basics$abs(
									$author$project$GridLevel$sub2$(from, center).b),
								e: $author$project$GridLevel$profileDirection$(
									revolution,
									radial,
									$author$project$GridLevel$unit2(
										$author$project$GridLevel$sub2$(to, center)))
							});
					}
				}(),
				k: function () {
					var _v3 = revolution.u;
					if (!_v3.$) {
						return $author$project$GridLevel$Along(
							$author$project$GridLevel$profileDirection$(
								revolution,
								radial,
								$author$project$GridLevel$rightNormal(t0)));
					} else {
						var center = _v3.a.b;
						var to = _v3.a.e;
						var from = _v3.a.c;
						var _v4 = $author$project$GridLevel$sub2$(to, center);
						var br = _v4.a;
						var bh = _v4.b;
						var _v5 = $author$project$GridLevel$sub2$(from, center);
						var ar = _v5.a;
						var ah = _v5.b;
						return $author$project$GridLevel$Radial(
							$author$project$GridLevel$sign((ar * bh) - (ah * br)));
					}
				}(),
				ai: $author$project$GridLevel$Along(out)
			};
		});
	var _v1 = $author$project$GridLevel$profileEnds(revolution.u);
	var p0 = _v1.a;
	var p1 = _v1.b;
	var ends = _Utils_ap(
		(p0.a > 0) ? _List_fromArray(
			[
				{
				t: circle(p0),
				k: $author$project$GridLevel$acrossCircle$(
					revolution,
					$author$project$GridLevel$rightNormal(t0)),
				ai: $author$project$GridLevel$acrossCircle$(
					revolution,
					$author$project$GridLevel$neg2(t0))
			}
			]) : _List_Nil,
		(p1.a > 0) ? _List_fromArray(
			[
				{
				t: circle(p1),
				k: $author$project$GridLevel$acrossCircle$(
					revolution,
					$author$project$GridLevel$rightNormal(t1)),
				ai: $author$project$GridLevel$acrossCircle$(revolution, t1)
			}
			]) : _List_Nil);
	return _Utils_ap(
		ends,
		_List_fromArray(
			[
				A2(
				side,
				revolution.m,
				$author$project$GridLevel$vneg(y)),
				A2(
				side,
				y,
				$author$project$GridLevel$vneg(revolution.m))
			]));
};
var $author$project$GridLevel$cellEdges = function (cell) {
	if (!cell.$) {
		var loop = cell.a.X;
		var normal = cell.a.k;
		return $elm$core$List$map$(
			function (curve) {
				return {
					t: curve,
					k: $author$project$GridLevel$Along(normal),
					ai: $author$project$GridLevel$flatOut$(normal, curve)
				};
			},
			loop);
	} else {
		var revolution = cell.a;
		return $author$project$GridLevel$revolutionEdges(revolution);
	}
};
var $elm$core$List$sort = function (xs) {
	return A2($elm$core$List$sortBy, $elm$core$Basics$identity, xs);
};
var $author$project$GridLevel$vkey = function (v) {
	return _List_fromArray(
		[v.m, v.n, v.o]);
};
var $author$project$GridLevel$curveKey = function (curve) {
	if (!curve.$) {
		var a = curve.a;
		var b = curve.b;
		return A2(
			$elm$core$List$cons,
			0,
			$elm$core$List$concat(
				$elm$core$List$sort(
					_List_fromArray(
						[
							$author$project$GridLevel$vkey(a),
							$author$project$GridLevel$vkey(b)
						]))));
	} else {
		var arc = curve.a;
		return A2(
			$elm$core$List$cons,
			1,
			_Utils_ap(
				$author$project$GridLevel$vkey(arc.b),
				_Utils_ap(
					_List_fromArray(
						[arc.p]),
					$elm$core$List$concat(
						$elm$core$List$sort(
							_List_fromArray(
								[
									$author$project$GridLevel$vkey(arc.c),
									$author$project$GridLevel$vkey(arc.e)
								]))))));
	}
};
var $author$project$GridLevel$edgeCounts = function (cells) {
	return $elm$core$List$foldl$(
		function (edge) {
			return A2(
				$elm$core$Dict$update,
				$author$project$GridLevel$curveKey(edge.t),
				function (count) {
					return $elm$core$Maybe$Just(
						$elm$core$Maybe$withDefault$(0, count) + 1);
				});
		},
		$elm$core$Dict$empty,
		$elm$core$List$concatMap$($author$project$GridLevel$cellEdges, cells));
};
var $author$project$GridLevel$openEdges = function (level) {
	var edges = $elm$core$List$concatMap$($author$project$GridLevel$cellEdges, level.V);
	var counts = $author$project$GridLevel$edgeCounts(level.V);
	return $elm$core$List$filter$(
		function (edge) {
			return _Utils_eq(
				$elm$core$Dict$get$(
					$author$project$GridLevel$curveKey(edge.t),
					counts),
				$elm$core$Maybe$Just(1));
		},
		edges);
};
var $author$project$Shapes$add$ = function (a, b) {
	return {m: a.m + b.m, n: a.n + b.n, o: a.o + b.o};
};
var $author$project$Shapes$add = F2($author$project$Shapes$add$);
var $author$project$Shapes$pathStep = 0.04;
var $author$project$Shapes$scale$ = function (s, a) {
	return {m: s * a.m, n: s * a.n, o: s * a.o};
};
var $author$project$Shapes$scale = F2($author$project$Shapes$scale$);
var $author$project$Shapes$clampFloat$ = function (low, high, x) {
	return ((x - low) < 0) ? low : (((x - high) > 0) ? high : x);
};
var $author$project$Shapes$clampFloat = F3($author$project$Shapes$clampFloat$);
var $author$project$Shapes$cross$ = function (a, b) {
	return {m: (a.n * b.o) - (a.o * b.n), n: (a.o * b.m) - (a.m * b.o), o: (a.m * b.n) - (a.n * b.m)};
};
var $author$project$Shapes$cross = F2($author$project$Shapes$cross$);
var $author$project$Shapes$dot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$Shapes$dot = F2($author$project$Shapes$dot$);
var $author$project$Shapes$isClosed = function (points) {
	var _v0 = _Utils_Tuple2(
		points,
		$elm$core$List$reverse(points));
	if (((_v0.a.b && _v0.a.b.b) && _v0.a.b.b.b) && _v0.b.b) {
		var _v1 = _v0.a;
		var first = _v1.a;
		var _v2 = _v1.b;
		var _v3 = _v2.b;
		var _v4 = _v0.b;
		var last = _v4.a;
		return $author$project$Shapes$distance$(first, last) < 1.0e-4;
	} else {
		return false;
	}
};
var $author$project$Shapes$normalize = function (a) {
	var length = $elm$core$Basics$sqrt(
		$author$project$Shapes$dot$(a, a));
	return (length > 0) ? $author$project$Shapes$scale$(1 / length, a) : a;
};
var $author$project$Shapes$sub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$Shapes$sub = F2($author$project$Shapes$sub$);
var $author$project$Shapes$sections$ = function (onSurface, points) {
	var closed = $author$project$Shapes$isClosed(points);
	var onLine = $elm$core$Array$fromList(
		$elm$core$List$map$(
			onSurface,
			closed ? $elm$core$List$take$(
				$elm$core$List$length(points) - 1,
				points) : points));
	var count = $elm$core$Array$length(onLine);
	var at = function (i) {
		return $elm$core$Maybe$withDefault$(
			{
				k: {m: 0, n: 1, o: 0},
				gQ: {m: 0, n: 0, o: 0}
			},
			$elm$core$Array$get$(
				closed ? A2($elm$core$Basics$modBy, count, i) : $elm$core$Basics$clamp$(0, count - 1, i),
				onLine));
	};
	var section = function (i) {
		var p = at(i);
		var rightOf = function (d) {
			return $author$project$Shapes$normalize(
				$author$project$Shapes$cross$(d, p.k));
		};
		var towards = function (j) {
			return $author$project$Shapes$normalize(
				$author$project$Shapes$sub$(
					at(j).gQ,
					p.gQ));
		};
		var _v0 = ((!closed) && (!i)) ? _Utils_Tuple2(
			towards(1),
			towards(1)) : (((!closed) && _Utils_eq(i, count - 1)) ? _Utils_Tuple2(
			$author$project$Shapes$scale$(
				-1,
				towards(i - 1)),
			$author$project$Shapes$scale$(
				-1,
				towards(i - 1))) : _Utils_Tuple2(
			$author$project$Shapes$scale$(
				-1,
				towards(i - 1)),
			towards(i + 1)));
		var into = _v0.a;
		var out = _v0.b;
		var bisector = $author$project$Shapes$normalize(
			$author$project$Shapes$add$(
				rightOf(into),
				rightOf(out)));
		var mitre = 1 / $author$project$Shapes$clampFloat$(
			0.35,
			1,
			$author$project$Shapes$dot$(
				bisector,
				rightOf(into)));
		return {
			hk: $author$project$Shapes$normalize(
				$author$project$Shapes$add$(into, out)),
			k: p.k,
			gQ: p.gQ,
			fq: $author$project$Shapes$scale$(mitre, bisector)
		};
	};
	return function (all) {
		return closed ? _Utils_ap(
			all,
			$elm$core$List$take$(1, all)) : all;
	}(
		$elm$core$List$map$(
			section,
			$elm$core$List$range$(0, count - 1)));
};
var $author$project$Shapes$sections = F2($author$project$Shapes$sections$);
var $author$project$Shapes$pathPaving$ = function (surface, width, points) {
	var toTuple = function (v) {
		return _Utils_Tuple3(v.m, v.n, v.o);
	};
	var sides = function (s) {
		return _List_fromArray(
			[
				toTuple(
				$author$project$Shapes$add$(
					s.gQ,
					$author$project$Shapes$scale$((-width) / 2, s.fq))),
				toTuple(
				$author$project$Shapes$add$(
					s.gQ,
					$author$project$Shapes$scale$(width / 2, s.fq)))
			]);
	};
	var onSurface = function (p) {
		var _v0 = $author$project$Surface$nearestPoint$(
			$ianmackenzie$elm_geometry$Point3d$meters$(p.m, p.n, p.o),
			surface);
		if (!_v0.$) {
			var nearest = _v0.a;
			return {
				k: $ianmackenzie$elm_geometry$Direction3d$unwrap(nearest.k),
				gQ: $ianmackenzie$elm_geometry$Point3d$toMeters(nearest.gQ)
			};
		} else {
			return {
				k: {m: 0, n: 1, o: 0},
				gQ: p
			};
		}
	};
	var across = $author$project$Shapes$sections$(
		onSurface,
		$author$project$Shapes$alongWall$(
			$author$project$Shapes$pathStep,
			$elm$core$List$map$($author$project$Shapes$fromTuple, points)));
	return {
		fn: $elm$core$List$concatMap$(sides, across),
		aJ: $elm$core$List$concatMap$(
			function (i) {
				return _List_fromArray(
					[
						_Utils_Tuple3(2 * i, (2 * i) + 1, (2 * i) + 2),
						_Utils_Tuple3((2 * i) + 1, (2 * i) + 3, (2 * i) + 2)
					]);
			},
			$elm$core$List$range$(
				0,
				$elm$core$List$length(across) - 2))
	};
};
var $author$project$Shapes$pathPaving = F3($author$project$Shapes$pathPaving$);
var $author$project$Shapes$pathWidth = 0.07;
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $elm$json$Json$Decode$map3 = _Json_map3;
var $author$project$MinimapWorker$linesDecoder = $elm$json$Json$Decode$list(
	$elm$json$Json$Decode$list(
		A4(
			$elm$json$Json$Decode$map3,
			F3(
				function (x, y, z) {
					return _Utils_Tuple3(x, y, z);
				}),
			A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$float),
			A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$float),
			A2($elm$json$Json$Decode$index, 2, $elm$json$Json$Decode$float))));
var $author$project$MinimapWorker$placedDecoder = A3(
	$elm$json$Json$Decode$map2,
	F2(
		function (walls, paths) {
			return {gO: paths, jE: walls};
		}),
	A2($elm$json$Json$Decode$field, 'walls', $author$project$MinimapWorker$linesDecoder),
	A2($elm$json$Json$Decode$field, 'paths', $author$project$MinimapWorker$linesDecoder));
var $author$project$Surface$buildOpen = $author$project$Surface$buildWith(
	{fi: true});
var $author$project$GridLevel$curveStart = function (curve) {
	if (!curve.$) {
		var a = curve.a;
		return a;
	} else {
		var arc = curve.a;
		return $author$project$GridLevel$vadd$(
			arc.b,
			$author$project$GridLevel$vscale$(arc.p, arc.c));
	}
};
var $author$project$GridLevel$vdot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$GridLevel$vdot = F2($author$project$GridLevel$vdot$);
var $author$project$GridLevel$cylinderOf$ = function (id, cell) {
	if (cell.$ === 1) {
		var revolution = cell.a;
		var _v1 = revolution.u;
		if (!_v1.$) {
			var _v2 = _v1.a;
			var r0 = _v2.a;
			var z0 = _v2.b;
			var _v3 = _v1.b;
			var r1 = _v3.a;
			var z1 = _v3.b;
			if (_Utils_eq(r0, r1) && (r0 > 0)) {
				var along = $author$project$GridLevel$vdot$(revolution.b, revolution.w);
				var onAxis = $author$project$GridLevel$vsub$(
					revolution.b,
					$author$project$GridLevel$vscale$(along, revolution.w));
				return $elm$core$Maybe$Just(
					{
						c: along + $elm$core$Basics$min$(z0, z1),
						bV: _Utils_ap(
							$author$project$GridLevel$vkey(onAxis),
							_Utils_ap(
								$author$project$GridLevel$vkey(revolution.w),
								_Utils_ap(
									$author$project$GridLevel$vkey(revolution.m),
									_List_fromArray(
										[
											r0,
											$author$project$GridLevel$sign(z1 - z0)
										])))),
						bX: id,
						cC: _Utils_update(
							revolution,
							{b: onAxis}),
						$7: $elm$core$List$map$(
							function ($) {
								return $.t;
							},
							$elm$core$List$take$(
								2,
								$elm$core$List$reverse(
									$author$project$GridLevel$revolutionEdges(revolution)))),
						e: along + $elm$core$Basics$max$(z0, z1)
					});
			} else {
				return $elm$core$Maybe$Nothing;
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$GridLevel$cylinderOf = F2($author$project$GridLevel$cylinderOf$);
var $author$project$GridLevel$direction = function (v) {
	return $ianmackenzie$elm_geometry$Direction3d$unsafe(
		{m: v.m, n: v.n, o: v.o});
};
var $author$project$GridLevel$meters = function (v) {
	return $ianmackenzie$elm_geometry$Point3d$meters$(v.m * $author$project$GridLevel$cellSize, v.n * $author$project$GridLevel$cellSize, v.o * $author$project$GridLevel$cellSize);
};
var $author$project$GridLevel$featureSpec = function (revolution) {
	var inHalfPlane = function (_v1) {
		var rho = _v1.a;
		var h = _v1.b;
		return $ianmackenzie$elm_geometry$Point2d$meters$(rho * $author$project$GridLevel$cellSize, h * $author$project$GridLevel$cellSize);
	};
	return {
		h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				gK: $author$project$GridLevel$meters(revolution.b),
				g6: $author$project$GridLevel$direction(revolution.m),
				g7: $author$project$GridLevel$direction(
					$author$project$GridLevel$vcross$(revolution.w, revolution.m)),
				jO: $author$project$GridLevel$direction(revolution.w)
			}),
		u: function () {
			var _v0 = revolution.u;
			if (!_v0.$) {
				var p = _v0.a;
				var q = _v0.b;
				return {
					gX: _List_fromArray(
						[
							$author$project$Surface$Line(
							{
								f_: inHalfPlane(q)
							})
						]),
					fz: inHalfPlane(p)
				};
			} else {
				var center = _v0.a.b;
				var to = _v0.a.e;
				var from = _v0.a.c;
				return {
					gX: _List_fromArray(
						[
							$author$project$Surface$Circle(
							{
								b: inHalfPlane(center),
								f_: inHalfPlane(to)
							})
						]),
					fz: inHalfPlane(from)
				};
			}
		}(),
		jg: $author$project$Surface$PartTurn(
			{
				c: $ianmackenzie$elm_units$Angle$degrees(0),
				e: $ianmackenzie$elm_units$Angle$degrees(90)
			})
	};
};
var $elm$core$Dict$fromList = function (assocs) {
	return $elm$core$List$foldl$(
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return $elm$core$Dict$insert$(key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $elm$core$Dict$member$ = function (key, dict) {
	var _v0 = $elm$core$Dict$get$(key, dict);
	if (!_v0.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Dict$member = F2($elm$core$Dict$member$);
var $author$project$GridLevel$flatComponents = function (flats) {
	if (!flats.b) {
		return _List_Nil;
	} else {
		var _v1 = flats.a;
		var first = _v1.b;
		var normal = first.k;
		var flatArray = $elm$core$Dict$fromList(flats);
		var cellsAlong = $elm$core$List$foldl$(
			F2(
				function (_v5, acc) {
					var index = _v5.a;
					var flat = _v5.b;
					return $elm$core$List$foldl$(
						function (curve) {
							return A2(
								$elm$core$Dict$update,
								$author$project$GridLevel$curveKey(curve),
								function (others) {
									return $elm$core$Maybe$Just(
										A2(
											$elm$core$List$cons,
											index,
											$elm$core$Maybe$withDefault$(_List_Nil, others)));
								});
						},
						acc,
						flat.X);
				}),
			$elm$core$Dict$empty,
			flats);
		var neighbours = function (flat) {
			return $elm$core$List$concatMap$(
				function (curve) {
					return $elm$core$Maybe$withDefault$(
						_List_Nil,
						$elm$core$Dict$get$(
							$author$project$GridLevel$curveKey(curve),
							cellsAlong));
				},
				flat.X);
		};
		var group = F3(
			function (queue, seen, acc) {
				group:
				while (true) {
					if (queue.b) {
						var index = queue.a;
						var rest = queue.b;
						if ($elm$core$Dict$member$(index, seen)) {
							var $temp$queue = rest;
							queue = $temp$queue;
							continue group;
						} else {
							var $temp$queue = _Utils_ap(
								$elm$core$Maybe$withDefault$(
									_List_Nil,
									$elm$core$Maybe$map$(
										neighbours,
										$elm$core$Dict$get$(index, flatArray))),
								rest),
								$temp$seen = $elm$core$Dict$insert$(index, 0, seen),
								$temp$acc = A2($elm$core$List$cons, index, acc);
							queue = $temp$queue;
							seen = $temp$seen;
							acc = $temp$acc;
							continue group;
						}
					} else {
						return _Utils_Tuple2(acc, seen);
					}
				}
			});
		var groups = F3(
			function (remaining, seen, acc) {
				groups:
				while (true) {
					if (remaining.b) {
						var index = remaining.a;
						var rest = remaining.b;
						if ($elm$core$Dict$member$(index, seen)) {
							var $temp$remaining = rest;
							remaining = $temp$remaining;
							continue groups;
						} else {
							var _v4 = A3(
								group,
								_List_fromArray(
									[index]),
								seen,
								_List_Nil);
							var members = _v4.a;
							var newSeen = _v4.b;
							var $temp$remaining = rest,
								$temp$seen = newSeen,
								$temp$acc = A2($elm$core$List$cons, members, acc);
							remaining = $temp$remaining;
							seen = $temp$seen;
							acc = $temp$acc;
							continue groups;
						}
					} else {
						return acc;
					}
				}
			});
		var boundary = function (members) {
			return $elm$core$List$filter$(
				function (curve) {
					return _Utils_eq(
						$elm$core$Maybe$Just(1),
						$elm$core$Maybe$map$(
							$elm$core$List$length,
							$elm$core$Dict$get$(
								$author$project$GridLevel$curveKey(curve),
								cellsAlong)));
				},
				$elm$core$List$concatMap$(
					function ($) {
						return $.X;
					},
					$elm$core$List$filterMap$(
						function (index) {
							return $elm$core$Dict$get$(index, flatArray);
						},
						members)));
		};
		return $elm$core$List$map$(
			function (members) {
				return {
					eM: boundary(members),
					gA: members,
					k: normal
				};
			},
			A3(
				groups,
				$elm$core$List$map$($elm$core$Tuple$first, flats),
				$elm$core$Dict$empty,
				_List_Nil));
	}
};
var $author$project$GridLevel$axes = _List_fromArray(
	[
		$author$project$GridLevel$ivec$(1, 0, 0),
		$author$project$GridLevel$ivec$(0, 1, 0),
		$author$project$GridLevel$ivec$(0, 0, 1)
	]);
var $author$project$GridLevel$planeAxes = function (normal) {
	var u = $elm$core$Maybe$withDefault$(
		$author$project$GridLevel$ivec$(1, 0, 0),
		$elm$core$List$head(
			$elm$core$List$filter$(
				function (a) {
					return !$author$project$GridLevel$vdot$(a, normal);
				},
				$author$project$GridLevel$axes)));
	return _Utils_Tuple2(
		u,
		$author$project$GridLevel$vcross$(normal, u));
};
var $author$project$GridLevel$flatSpec$ = function (normal, boundary) {
	var offset = $elm$core$Maybe$withDefault$(
		0,
		$elm$core$Maybe$map$(
			A2(
				$elm$core$Basics$composeR,
				$author$project$GridLevel$curveStart,
				$author$project$GridLevel$vdot(normal)),
			$elm$core$Maybe$andThen$(
				$elm$core$List$head,
				$elm$core$List$head(boundary))));
	var origin = $author$project$GridLevel$vscale$(offset, normal);
	var _v0 = $author$project$GridLevel$planeAxes(normal);
	var u = _v0.a;
	var v = _v0.b;
	var inPlane = function (p) {
		return $ianmackenzie$elm_geometry$Point2d$meters$(
			$author$project$GridLevel$vdot$(
				$author$project$GridLevel$vsub$(p, origin),
				u) * $author$project$GridLevel$cellSize,
			$author$project$GridLevel$vdot$(
				$author$project$GridLevel$vsub$(p, origin),
				v) * $author$project$GridLevel$cellSize);
	};
	var edge = function (curve) {
		if (!curve.$) {
			var a = curve.a;
			return $author$project$Surface$Straight(
				inPlane(a));
		} else {
			var arc = curve.a;
			return $author$project$Surface$Arc(
				{
					b: inPlane(arc.b),
					fz: inPlane(
						$author$project$GridLevel$curveStart(curve)),
					jh: _Utils_eq(
						$author$project$GridLevel$vcross$(arc.c, arc.e),
						normal) ? $ianmackenzie$elm_units$Angle$degrees(90) : $ianmackenzie$elm_units$Angle$degrees(-90)
				});
		}
	};
	return {
		eM: $elm$core$List$map$(
			$elm$core$List$map(edge),
			boundary),
		iO: $ianmackenzie$elm_geometry$SketchPlane3d$unsafe(
			{
				gK: $author$project$GridLevel$meters(origin),
				g6: $author$project$GridLevel$direction(u),
				g7: $author$project$GridLevel$direction(v)
			})
	};
};
var $author$project$GridLevel$flatSpec = F2($author$project$GridLevel$flatSpec$);
var $author$project$GridLevel$curveEnd = function (curve) {
	if (!curve.$) {
		var b = curve.b;
		return b;
	} else {
		var arc = curve.a;
		return $author$project$GridLevel$vadd$(
			arc.b,
			$author$project$GridLevel$vscale$(arc.p, arc.e));
	}
};
var $elm$core$Dict$values = function (dict) {
	return $elm$core$Dict$foldr$(
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$GridLevel$loops = function (curves) {
	var take = F2(
		function (point, dict) {
			var _v7 = $elm$core$Dict$get$(
				$author$project$GridLevel$vkey(point),
				dict);
			if ((!_v7.$) && _v7.a.b) {
				var _v8 = _v7.a;
				var curve = _v8.a;
				var rest = _v8.b;
				return $elm$core$Maybe$Just(
					_Utils_Tuple2(
						curve,
						$elm$core$List$isEmpty(rest) ? $elm$core$Dict$remove$(
							$author$project$GridLevel$vkey(point),
							dict) : $elm$core$Dict$insert$(
							$author$project$GridLevel$vkey(point),
							rest,
							dict)));
			} else {
				return $elm$core$Maybe$Nothing;
			}
		});
	var follow = F3(
		function (loopStart, dict, acc) {
			follow:
			while (true) {
				if (acc.b) {
					var last = acc.a;
					if (_Utils_eq(
						$author$project$GridLevel$curveEnd(last),
						loopStart)) {
						return _Utils_Tuple2(
							$elm$core$List$reverse(acc),
							dict);
					} else {
						var _v1 = A2(
							take,
							$author$project$GridLevel$curveEnd(last),
							dict);
						if (!_v1.$) {
							var _v2 = _v1.a;
							var next = _v2.a;
							var rest = _v2.b;
							var $temp$dict = rest,
								$temp$acc = A2($elm$core$List$cons, next, acc);
							dict = $temp$dict;
							acc = $temp$acc;
							continue follow;
						} else {
							return _Utils_Tuple2(
								$elm$core$List$reverse(acc),
								dict);
						}
					}
				} else {
					return _Utils_Tuple2(_List_Nil, dict);
				}
			}
		});
	var byStart = $elm$core$List$foldl$(
		function (curve) {
			return A2(
				$elm$core$Dict$update,
				$author$project$GridLevel$vkey(
					$author$project$GridLevel$curveStart(curve)),
				function (others) {
					return $elm$core$Maybe$Just(
						A2(
							$elm$core$List$cons,
							curve,
							$elm$core$Maybe$withDefault$(_List_Nil, others)));
				});
		},
		$elm$core$Dict$empty,
		curves);
	var all = F2(
		function (dict, acc) {
			all:
			while (true) {
				var _v3 = $elm$core$List$head(
					$elm$core$List$concat(
						$elm$core$Dict$values(dict)));
				if (!_v3.$) {
					var curve = _v3.a;
					var _v4 = A2(
						take,
						$author$project$GridLevel$curveStart(curve),
						dict);
					if (!_v4.$) {
						var _v5 = _v4.a;
						var first = _v5.a;
						var rest = _v5.b;
						var _v6 = A3(
							follow,
							$author$project$GridLevel$curveStart(first),
							rest,
							_List_fromArray(
								[first]));
						var loop = _v6.a;
						var remaining = _v6.b;
						var $temp$dict = remaining,
							$temp$acc = A2($elm$core$List$cons, loop, acc);
						dict = $temp$dict;
						acc = $temp$acc;
						continue all;
					} else {
						return acc;
					}
				} else {
					return acc;
				}
			}
		});
	return A2(all, byStart, _List_Nil);
};
var $author$project$GridLevel$unitOf = function (v) {
	return {
		m: $author$project$GridLevel$sign(v.m),
		n: $author$project$GridLevel$sign(v.n),
		o: $author$project$GridLevel$sign(v.o)
	};
};
var $author$project$GridLevel$mergeAlong$ = function (otherSide, loop) {
	var joins = F2(
		function (a, b) {
			var _v8 = _Utils_Tuple2(a, b);
			if ((!_v8.a.$) && (!_v8.b.$)) {
				var _v9 = _v8.a;
				var a0 = _v9.a;
				var a1 = _v9.b;
				var _v10 = _v8.b;
				var b0 = _v10.a;
				var b1 = _v10.b;
				return _Utils_eq(a1, b0) && (_Utils_eq(
					$author$project$GridLevel$unitOf(
						$author$project$GridLevel$vsub$(a1, a0)),
					$author$project$GridLevel$unitOf(
						$author$project$GridLevel$vsub$(b1, b0))) && _Utils_eq(
					otherSide(a),
					otherSide(b)));
			} else {
				return false;
			}
		});
	var rotated = function () {
		var _v4 = $elm$core$List$head(
			$elm$core$List$filter$(
				function (_v5) {
					var _v6 = _v5.b;
					var previous = _v6.a;
					var curve = _v6.b;
					return !A2(joins, previous, curve);
				},
				$elm$core$List$indexedMap$(
					$elm$core$Tuple$pair,
					A3(
						$elm$core$List$map2,
						$elm$core$Tuple$pair,
						_Utils_ap(
							$elm$core$List$drop$(
								$elm$core$List$length(loop) - 1,
								loop),
							$elm$core$List$take$(
								$elm$core$List$length(loop) - 1,
								loop)),
						loop))));
		if (!_v4.$) {
			var _v7 = _v4.a;
			var index = _v7.a;
			return _Utils_ap(
				$elm$core$List$drop$(index, loop),
				$elm$core$List$take$(index, loop));
		} else {
			return loop;
		}
	}();
	return $elm$core$List$reverse(
		$elm$core$List$foldl$(
			F2(
				function (curve, acc) {
					var _v0 = _Utils_Tuple2(acc, curve);
					if ((_v0.a.b && (!_v0.a.a.$)) && (!_v0.b.$)) {
						var _v1 = _v0.a;
						var _v2 = _v1.a;
						var a0 = _v2.a;
						var a1 = _v2.b;
						var rest = _v1.b;
						var _v3 = _v0.b;
						var b1 = _v3.b;
						return A2(
							joins,
							$author$project$GridLevel$Segment$(a0, a1),
							curve) ? A2(
							$elm$core$List$cons,
							$author$project$GridLevel$Segment$(a0, b1),
							rest) : A2($elm$core$List$cons, curve, acc);
					} else {
						return A2($elm$core$List$cons, curve, acc);
					}
				}),
			_List_Nil,
			rotated));
};
var $author$project$GridLevel$mergeAlong = F2($author$project$GridLevel$mergeAlong$);
var $author$project$GridLevel$mergeRun = function (run) {
	var _v0 = _Utils_Tuple2(
		run,
		$elm$core$List$reverse(run));
	if (_v0.a.b && _v0.b.b) {
		var _v1 = _v0.a;
		var first = _v1.a;
		var _v2 = _v0.b;
		var last = _v2.a;
		var _v3 = first.cC.u;
		if (!_v3.$) {
			var _v4 = _v3.a;
			var r = _v4.a;
			var z0 = _v4.b;
			var _v5 = _v3.b;
			var z1 = _v5.b;
			var revolution = first.cC;
			return $elm$core$Maybe$Just(
				_Utils_update(
					revolution,
					{
						u: (_Utils_cmp(z1, z0) > 0) ? $author$project$GridLevel$ProfileLine$(
							_Utils_Tuple2(r, first.c),
							_Utils_Tuple2(r, last.e)) : $author$project$GridLevel$ProfileLine$(
							_Utils_Tuple2(r, last.e),
							_Utils_Tuple2(r, first.c))
					}));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$GridLevel$cellsSurface = function (cells) {
	var labelOf = F2(
		function (labels, id) {
			return $elm$core$Maybe$withDefault$(
				_List_fromArray(
					[2, id]),
				$elm$core$Dict$get$(id, labels));
		});
	var indexed = $elm$core$List$indexedMap$($elm$core$Tuple$pair, cells);
	var owners = $elm$core$List$foldl$(
		F2(
			function (_v13, acc) {
				var id = _v13.a;
				var cell = _v13.b;
				return $elm$core$List$foldl$(
					function (edge) {
						return A2(
							$elm$core$Dict$update,
							$author$project$GridLevel$curveKey(edge.t),
							function (others) {
								return $elm$core$Maybe$Just(
									A2(
										$elm$core$List$cons,
										id,
										$elm$core$Maybe$withDefault$(_List_Nil, others)));
							});
					},
					acc,
					$author$project$GridLevel$cellEdges(cell));
			}),
		$elm$core$Dict$empty,
		indexed);
	var cylinders = $elm$core$List$filterMap$(
		function (_v12) {
			var id = _v12.a;
			var cell = _v12.b;
			return $author$project$GridLevel$cylinderOf$(id, cell);
		},
		indexed);
	var components = $elm$core$List$concatMap$(
		$author$project$GridLevel$flatComponents,
		$elm$core$Dict$values(
			$elm$core$List$foldl$(
				function (_v11) {
					var id = _v11.a;
					var flat = _v11.b;
					return A2(
						$elm$core$Dict$update,
						_Utils_ap(
							$author$project$GridLevel$vkey(flat.k),
							_List_fromArray(
								[
									$elm$core$Maybe$withDefault$(
									0,
									$elm$core$Maybe$map$(
										A2(
											$elm$core$Basics$composeR,
											$author$project$GridLevel$curveStart,
											$author$project$GridLevel$vdot(flat.k)),
										$elm$core$List$head(flat.X)))
								])),
						function (others) {
							return $elm$core$Maybe$Just(
								A2(
									$elm$core$List$cons,
									_Utils_Tuple2(id, flat),
									$elm$core$Maybe$withDefault$(_List_Nil, others)));
						});
				},
				$elm$core$Dict$empty,
				$elm$core$List$filterMap$(
					function (_v9) {
						var id = _v9.a;
						var cell = _v9.b;
						if (!cell.$) {
							var flat = cell.a;
							return $elm$core$Maybe$Just(
								_Utils_Tuple2(id, flat));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					},
					indexed))));
	var initialLabels = $elm$core$Dict$fromList(
		_Utils_ap(
			$elm$core$List$map$(
				function (cylinder) {
					return _Utils_Tuple2(
						cylinder.bX,
						A2($elm$core$List$cons, 1, cylinder.bV));
				},
				cylinders),
			$elm$core$List$concat(
				$elm$core$List$indexedMap$(
					F2(
						function (index, component) {
							return $elm$core$List$map$(
								function (id) {
									return _Utils_Tuple2(
										id,
										_List_fromArray(
											[0, index]));
								},
								component.gA);
						}),
					components))));
	var across = F3(
		function (labels, own, curve) {
			return $elm$core$Maybe$withDefault$(
				_List_fromArray(
					[-1]),
				$elm$core$List$head(
					$elm$core$List$filter$(
						$elm$core$Basics$neq(own),
						$elm$core$List$map$(
							labelOf(labels),
							$elm$core$Maybe$withDefault$(
								_List_Nil,
								$elm$core$Dict$get$(
									$author$project$GridLevel$curveKey(curve),
									owners))))));
		});
	var runsWith = function (labels) {
		return $elm$core$List$concatMap$(
			function (group) {
				return $elm$core$List$map$(
					A2($elm$core$Basics$composeR, $elm$core$Tuple$first, $elm$core$List$reverse),
					$elm$core$List$foldl$(
						F2(
							function (cylinder, runs) {
								var sides = $elm$core$List$map$(
									A2(
										across,
										labels,
										A2(labelOf, labels, cylinder.bX)),
									cylinder.$7);
								if (runs.b) {
									var _v7 = runs.a;
									var run = _v7.a;
									var runSides = _v7.b;
									var rest = runs.b;
									if (run.b) {
										var last = run.a;
										return (_Utils_eq(last.e, cylinder.c) && _Utils_eq(runSides, sides)) ? A2(
											$elm$core$List$cons,
											_Utils_Tuple2(
												A2($elm$core$List$cons, cylinder, run),
												runSides),
											rest) : A2(
											$elm$core$List$cons,
											_Utils_Tuple2(
												_List_fromArray(
													[cylinder]),
												sides),
											runs);
									} else {
										return A2(
											$elm$core$List$cons,
											_Utils_Tuple2(
												_List_fromArray(
													[cylinder]),
												sides),
											rest);
									}
								} else {
									return _List_fromArray(
										[
											_Utils_Tuple2(
											_List_fromArray(
												[cylinder]),
											sides)
										]);
								}
							}),
						_List_Nil,
						A2(
							$elm$core$List$sortBy,
							function ($) {
								return $.c;
							},
							group)));
			},
			$elm$core$Dict$values(
				$elm$core$List$foldl$(
					function (cylinder) {
						return A2(
							$elm$core$Dict$update,
							cylinder.bV,
							function (others) {
								return $elm$core$Maybe$Just(
									A2(
										$elm$core$List$cons,
										cylinder,
										$elm$core$Maybe$withDefault$(_List_Nil, others)));
							});
					},
					$elm$core$Dict$empty,
					cylinders)));
	};
	var settle = F2(
		function (labels, count) {
			settle:
			while (true) {
				var runs = runsWith(labels);
				var newLabels = $elm$core$List$foldl$(
					function (_v1) {
						var id = _v1.a;
						var label = _v1.b;
						return A2($elm$core$Dict$insert, id, label);
					},
					labels,
					$elm$core$List$concatMap$(
						function (run) {
							if (run.b) {
								var first = run.a;
								return $elm$core$List$map$(
									function (cylinder) {
										return _Utils_Tuple2(
											cylinder.bX,
											A2(
												$elm$core$List$cons,
												1,
												_Utils_ap(
													cylinder.bV,
													_List_fromArray(
														[first.c]))));
									},
									run);
							} else {
								return _List_Nil;
							}
						},
						runs));
				if (_Utils_eq(newLabels, labels) || (count <= 0)) {
					return _Utils_Tuple2(labels, runs);
				} else {
					var $temp$labels = newLabels,
						$temp$count = count - 1;
					labels = $temp$labels;
					count = $temp$count;
					continue settle;
				}
			}
		});
	var _v2 = A2(settle, initialLabels, 20);
	var finalLabels = _v2.a;
	var finalRuns = _v2.b;
	var otherRound = $elm$core$List$filterMap$(
		function (_v3) {
			var id = _v3.a;
			var cell = _v3.b;
			var _v4 = _Utils_Tuple2(
				cell,
				$elm$core$Dict$get$(id, finalLabels));
			if ((_v4.a.$ === 1) && (_v4.b.$ === 1)) {
				var revolution = _v4.a.a;
				var _v5 = _v4.b;
				return $elm$core$Maybe$Just(revolution);
			} else {
				return $elm$core$Maybe$Nothing;
			}
		},
		indexed);
	return A2(
		$author$project$Surface$buildOpen,
		$elm$core$List$indexedMap$(
			F2(
				function (index, component) {
					return $author$project$GridLevel$flatSpec$(
						component.k,
						$elm$core$List$map$(
							$author$project$GridLevel$mergeAlong(
								A2(
									across,
									finalLabels,
									_List_fromArray(
										[0, index]))),
							$author$project$GridLevel$loops(component.eM)));
				}),
			components),
		$elm$core$List$map$(
			$author$project$GridLevel$featureSpec,
			_Utils_ap(
				$elm$core$List$filterMap$($author$project$GridLevel$mergeRun, finalRuns),
				otherRound)));
};
var $author$project$GridLevel$surface = function (level) {
	return $author$project$GridLevel$cellsSurface(level.V);
};
var $author$project$Step$Decode$Failed = function (a) {
	return {$: 1, a: a};
};
var $author$project$Step$Decode$Succeeded$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $author$project$Step$Decode$Succeeded = F2($author$project$Step$Decode$Succeeded$);
var $author$project$Step$Decode$UnexpectedType = {$: 2};
var $author$project$Step$Decode$errorMessage = function (message) {
	return $author$project$Step$Decode$Failed(
		{by: _List_Nil, bB: message});
};
var $author$project$Step$Decode$internalError = function (message) {
	return $author$project$Step$Decode$errorMessage('Internal error in STEP parsing: ' + message);
};
var $author$project$Step$Decode$wrongNumberOfSubmatches = $author$project$Step$Decode$internalError('wrong number of submatches');
var $author$project$Step$Decode$decodeEntity$ = function (_v0, entityLine) {
	var chomp = _v0.b;
	var _v1 = A2(chomp, entityLine, _List_Nil);
	switch (_v1.$) {
		case 0:
			if (!_v1.b.b) {
				var value = _v1.a;
				return $author$project$Step$Decode$Succeeded$(value, 0);
			} else {
				var _v2 = _v1.b;
				return $author$project$Step$Decode$wrongNumberOfSubmatches;
			}
		case 1:
			var message = _v1.a.bB;
			var entityIds = _v1.a.by;
			var updatedEntityIds = _Utils_eq(
				$elm$core$List$head(entityIds),
				$elm$core$Maybe$Just(entityLine.bX)) ? entityIds : A2($elm$core$List$cons, entityLine.bX, entityIds);
			return $author$project$Step$Decode$Failed(
				{by: updatedEntityIds, bB: message});
		default:
			return $author$project$Step$Decode$UnexpectedType;
	}
};
var $author$project$Step$Decode$decodeEntity = F2($author$project$Step$Decode$decodeEntity$);
var $author$project$Step$Decode$idString = function (id) {
	return '#' + $elm$core$String$fromInt(id);
};
var $author$project$Step$Decode$reportError = function (_v0) {
	var message = _v0.bB;
	var entityIds = _v0.by;
	var entityChain = $elm$core$String$join$(
		'->',
		$elm$core$List$map$($author$project$Step$Decode$idString, entityIds));
	return 'In ' + (entityChain + (': ' + message));
};
var $author$project$Step$Decode$decodeAllHelp$ = function (entityDecoder, file, givenContext, entityString, foldState) {
	var _v0 = foldState;
	var id = _v0.a;
	var currentResult = _v0.b;
	if (entityString === '') {
		return _Utils_Tuple2(id + 1, currentResult);
	} else {
		if (!currentResult.$) {
			var accumulated = currentResult.a;
			var entityLine = {W: givenContext, ac: file, bX: id, am: entityString};
			var _v2 = $author$project$Step$Decode$decodeEntity$(entityDecoder, entityLine);
			switch (_v2.$) {
				case 2:
					return _Utils_Tuple2(id + 1, currentResult);
				case 0:
					var value = _v2.a;
					return _Utils_Tuple2(
						id + 1,
						$elm$core$Result$Ok(
							A2($elm$core$List$cons, value, accumulated)));
				default:
					var error = _v2.a;
					return _Utils_Tuple2(
						id,
						$elm$core$Result$Err(
							$author$project$Step$Decode$reportError(error)));
			}
		} else {
			return foldState;
		}
	}
};
var $author$project$Step$Decode$decodeAllHelp = F5($author$project$Step$Decode$decodeAllHelp$);
var $author$project$Step$Decode$all$ = function (entityDecoder, file, givenContext) {
	var _v0 = file;
	var entities = _v0.b;
	return $elm$core$Result$map$(
		$elm$core$List$reverse,
		$elm$core$Array$foldl$(
			A3($author$project$Step$Decode$decodeAllHelp, entityDecoder, file, givenContext),
			_Utils_Tuple2(
				0,
				$elm$core$Result$Ok(_List_Nil)),
			entities).b);
};
var $author$project$Step$Decode$all = F3($author$project$Step$Decode$all$);
var $elm$core$Result$andThen$ = function (callback, result) {
	if (!result.$) {
		var value = result.a;
		return callback(value);
	} else {
		var msg = result.a;
		return $elm$core$Result$Err(msg);
	}
};
var $elm$core$Result$andThen = F2($elm$core$Result$andThen$);
var $author$project$StepImport$combine = function (results) {
	return $elm$core$List$foldr$(
		$elm$core$Result$map2($elm$core$List$cons),
		$elm$core$Result$Ok(_List_Nil),
		results);
};
var $author$project$StepImport$CircleCurve = function (a) {
	return {$: 1, a: a};
};
var $author$project$StepImport$Cone$ = function (a, b, c) {
	return {$: 2, a: a, b: b, c: c};
};
var $author$project$StepImport$Cone = F3($author$project$StepImport$Cone$);
var $author$project$StepImport$Cylinder$ = function (a, b) {
	return {$: 1, a: a, b: b};
};
var $author$project$StepImport$Cylinder = F2($author$project$StepImport$Cylinder$);
var $author$project$StepImport$LineCurve = {$: 0};
var $author$project$StepImport$Plane = function (a) {
	return {$: 0, a: a};
};
var $author$project$StepImport$Sphere$ = function (a, b) {
	return {$: 3, a: a, b: b};
};
var $author$project$StepImport$Sphere = F2($author$project$StepImport$Sphere$);
var $author$project$StepImport$Torus$ = function (a, b, c) {
	return {$: 4, a: a, b: b, c: c};
};
var $author$project$StepImport$Torus = F3($author$project$StepImport$Torus$);
var $elm$core$Tuple$mapFirst$ = function (func, _v0) {
	var x = _v0.a;
	var y = _v0.b;
	return _Utils_Tuple2(
		func(x),
		y);
};
var $elm$core$Tuple$mapFirst = F2($elm$core$Tuple$mapFirst$);
var $author$project$StepImport$convertFace$ = function (convert, face_) {
	var placement_ = function (p) {
		return {
			w: $elm$core$Maybe$map$(convert.dU, p.w),
			z: convert.dk(p.z),
			cB: $elm$core$Maybe$map$(convert.dU, p.cB)
		};
	};
	var curve_ = function (c) {
		if (!c.$) {
			return $author$project$StepImport$LineCurve;
		} else {
			var circle = c.a;
			return $author$project$StepImport$CircleCurve(
				{
					H: placement_(circle.H),
					p: convert.aR(circle.p)
				});
		}
	};
	var edge = function (e) {
		return _Utils_update(
			e,
			{
				t: curve_(e.t),
				f_: convert.dk(e.f_),
				fz: convert.dk(e.fz)
			});
	};
	return _Utils_update(
		face_,
		{
			at: $elm$core$List$map$(
				function (b) {
					return _Utils_update(
						b,
						{
							bS: $elm$core$List$map$(
								$elm$core$Tuple$mapFirst(edge),
								b.bS)
						});
				},
				face_.at),
			bT: function () {
				var _v0 = face_.bT;
				switch (_v0.$) {
					case 0:
						var p = _v0.a;
						return $author$project$StepImport$Plane(
							placement_(p));
					case 1:
						var p = _v0.a;
						var r = _v0.b;
						return $author$project$StepImport$Cylinder$(
							placement_(p),
							convert.aR(r));
					case 2:
						var p = _v0.a;
						var r = _v0.b;
						var semiAngle = _v0.c;
						return $author$project$StepImport$Cone$(
							placement_(p),
							convert.aR(r),
							convert.fS(semiAngle));
					case 3:
						var p = _v0.a;
						var r = _v0.b;
						return $author$project$StepImport$Sphere$(
							placement_(p),
							convert.aR(r));
					default:
						var p = _v0.a;
						var major = _v0.b;
						var minor = _v0.c;
						return $author$project$StepImport$Torus$(
							placement_(p),
							convert.aR(major),
							convert.aR(minor));
				}
			}()
		});
};
var $author$project$StepImport$convertFace = F2($author$project$StepImport$convertFace$);
var $author$project$Surface$errorToString = function (error) {
	switch (error.$) {
		case 0:
			var description = error.a;
			return 'No piece meets ' + description;
		case 1:
			var description = error.a;
			return 'More than one piece meets ' + description;
		case 2:
			return 'A flat has a zero length edge';
		default:
			return 'A feature profile has a zero length segment';
	}
};
var $elm$core$String$contains = _String_contains;
var $elm$regex$Regex$Match$ = function (match, index, number, submatches) {
	return {d1: index, ii: match, fg: number, fB: submatches};
};
var $elm$regex$Regex$Match = F4($elm$regex$Regex$Match$);
var $elm$regex$Regex$find = _Regex_findAtMost(_Regex_infinity);
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{hz: false, it: false},
		string);
};
var $elm$regex$Regex$never = _Regex_never;
var $author$project$StepImport$regex = function (string) {
	return $elm$core$Maybe$withDefault$(
		$elm$regex$Regex$never,
		$elm$regex$Regex$fromString(string));
};
var $elm$core$String$startsWith = _String_startsWith;
var $author$project$StepImport$explain$ = function (text, message) {
	var typeOf = function (id) {
		return $elm$core$Maybe$withDefault$(
			'?',
			$elm$core$Maybe$andThen$(
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.fB;
					},
					A2(
						$elm$core$Basics$composeR,
						$elm$core$List$head,
						$elm$core$Maybe$andThen($elm$core$Basics$identity))),
				$elm$core$List$head(
					A2(
						$elm$regex$Regex$find,
						$author$project$StepImport$regex('(?:^|[;\\s])#' + (id + '\\s*=\\s*([A-Z0-9_]*)')),
						text))));
	};
	var ids = $elm$core$List$filterMap$(
		A2(
			$elm$core$Basics$composeR,
			function ($) {
				return $.fB;
			},
			A2(
				$elm$core$Basics$composeR,
				$elm$core$List$head,
				$elm$core$Maybe$andThen($elm$core$Basics$identity))),
		A2(
			$elm$regex$Regex$find,
			$author$project$StepImport$regex('#(\\d+)'),
			$elm$core$Maybe$withDefault$(
				'',
				$elm$core$List$head(
					$elm$core$String$split$(':', message)))));
	var faceId = $elm$core$List$head(
		$elm$core$List$filter$(
			function (id) {
				return typeOf(id) === 'ADVANCED_FACE';
			},
			ids));
	var _v0 = _Utils_Tuple2(
		faceId,
		$elm$core$List$head(
			$elm$core$List$reverse(ids)));
	if ((!_v0.a.$) && (!_v0.b.$)) {
		var faceId_ = _v0.a.a;
		var last = _v0.b.a;
		var lastType = typeOf(last);
		return A2($elm$core$String$contains, 'unexpected type', message) ? ('Face #' + (faceId_ + (' uses ' + (($elm$core$List$any$(
			function (vowel) {
				return A2($elm$core$String$startsWith, vowel, lastType);
			},
			_List_fromArray(
				['A', 'E', 'I', 'O', 'U'])) ? 'an ' : 'a ') + (lastType + (' (#' + (last + '), which can\'t be imported: only planes, cylinders, cones, spheres and tori with edges that are lines or circles can'))))))) : ('Face #' + (faceId_ + (': ' + message)));
	} else {
		return message;
	}
};
var $author$project$StepImport$explain = F2($author$project$StepImport$explain$);
var $elm$core$Result$mapError$ = function (f, result) {
	if (!result.$) {
		var v = result.a;
		return $elm$core$Result$Ok(v);
	} else {
		var e = result.a;
		return $elm$core$Result$Err(
			f(e));
	}
};
var $elm$core$Result$mapError = F2($elm$core$Result$mapError$);
var $author$project$Step$Decode$File$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $author$project$Step$Decode$File = F2($author$project$Step$Decode$File$);
var $author$project$Step$Pattern$Pattern = function (a) {
	return {$: 0, a: a};
};
var $author$project$Step$Pattern$comment = $author$project$Step$Pattern$Pattern('/\\*[\\s\\S]*?\\*/');
var $author$project$Step$Pattern$Capturing = 0;
var $author$project$Step$Pattern$capturing = 0;
var $elm$core$String$concat = function (strings) {
	return $elm$core$String$join$('', strings);
};
var $elm$core$List$intersperse$ = function (sep, xs) {
	if (!xs.b) {
		return _List_Nil;
	} else {
		var hd = xs.a;
		var tl = xs.b;
		var step = F2(
			function (x, rest) {
				return A2(
					$elm$core$List$cons,
					sep,
					A2($elm$core$List$cons, x, rest));
			});
		var spersed = $elm$core$List$foldr$(step, _List_Nil, tl);
		return A2($elm$core$List$cons, hd, spersed);
	}
};
var $elm$core$List$intersperse = F2($elm$core$List$intersperse$);
var $author$project$Step$Pattern$NonCapturing = 1;
var $author$project$Step$Pattern$nonCapturing = 1;
var $author$project$Step$Pattern$toString$ = function (mode, pattern) {
	toString:
	while (true) {
		switch (pattern.$) {
			case 0:
				var literal = pattern.a;
				return literal;
			case 1:
				var optionalPattern = pattern.a;
				return $elm$core$String$concat(
					_List_fromArray(
						[
							'(?:',
							$author$project$Step$Pattern$toString$(mode, optionalPattern),
							')?'
						]));
			case 2:
				var patterns = pattern.a;
				return $elm$core$String$concat(
					_List_fromArray(
						[
							'(?:',
							$elm$core$String$concat(
							$elm$core$List$intersperse$(
								'|',
								$elm$core$List$map$(
									function (alternative) {
										return '(?:' + ($author$project$Step$Pattern$toString$(mode, alternative) + ')');
									},
									patterns))),
							')'
						]));
			case 3:
				var capturedPattern = pattern.a;
				var nonCapturingPattern = $author$project$Step$Pattern$toString$($author$project$Step$Pattern$nonCapturing, capturedPattern);
				if (!mode) {
					return '(' + (nonCapturingPattern + ')');
				} else {
					return nonCapturingPattern;
				}
			case 4:
				var ignoredPattern = pattern.a;
				var $temp$mode = $author$project$Step$Pattern$nonCapturing,
					$temp$pattern = ignoredPattern;
				mode = $temp$mode;
				pattern = $temp$pattern;
				continue toString;
			case 5:
				var patterns = pattern.a;
				return $elm$core$String$concat(
					$elm$core$List$map$(
						$author$project$Step$Pattern$toString(mode),
						patterns));
			case 6:
				var repeatingPattern = pattern.a;
				return '(?:' + ($author$project$Step$Pattern$toString$(mode, repeatingPattern) + ')*');
			default:
				var repeatingPattern = pattern.a;
				return '(?:' + ($author$project$Step$Pattern$toString$(mode, repeatingPattern) + ')+');
		}
	}
};
var $author$project$Step$Pattern$toString = F2($author$project$Step$Pattern$toString$);
var $author$project$Step$Pattern$compile = function (pattern) {
	return $elm$core$Maybe$withDefault$(
		$elm$regex$Regex$never,
		A2(
			$elm$regex$Regex$fromStringWith,
			{hz: true, it: false},
			$author$project$Step$Pattern$toString$($author$project$Step$Pattern$capturing, pattern)));
};
var $elm$regex$Regex$replace = _Regex_replaceAtMost(_Regex_infinity);
var $elm$core$String$replace$ = function (before, after, string) {
	return $elm$core$String$join$(
		after,
		$elm$core$String$split$(before, string));
};
var $elm$core$String$replace = F3($elm$core$String$replace$);
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft$ = function (n, string) {
	return (n < 1) ? string : A3(
		$elm$core$String$slice,
		n,
		$elm$core$String$length(string),
		string);
};
var $elm$core$String$dropLeft = F2($elm$core$String$dropLeft$);
var $author$project$Step$Hex$charToInt = function (_char) {
	var charCode = $elm$core$Char$toCode(_char);
	return ((charCode >= 48) && (charCode <= 57)) ? (charCode - 48) : (((charCode >= 65) && (charCode <= 70)) ? (charCode - 55) : 0);
};
var $elm$core$String$foldr = _String_foldr;
var $elm$core$Char$fromCode = _Char_fromCode;
var $elm$core$String$fromList = _String_fromList;
var $author$project$Step$String$replaceHexString$ = function (chunkSize, hexString) {
	var foldResult = A3(
		$elm$core$String$foldr,
		F2(
			function (hexCharacter, _v0) {
				var multiplier = _v0.d8;
				var current = _v0.dQ;
				var index = _v0.d1;
				var unicodeCharacters = _v0.dw;
				var updated = current + (multiplier * $author$project$Step$Hex$charToInt(hexCharacter));
				var nextIndex = index + 1;
				return (_Utils_cmp(nextIndex, chunkSize) < 0) ? {dQ: updated, d1: nextIndex, d8: 16 * multiplier, dw: unicodeCharacters} : {
					dQ: 0,
					d1: 0,
					d8: 1,
					dw: A2(
						$elm$core$List$cons,
						$elm$core$Char$fromCode(updated),
						unicodeCharacters)
				};
			}),
		{dQ: 0, d1: 0, d8: 1, dw: _List_Nil},
		hexString);
	return $elm$core$String$fromList(foldResult.dw);
};
var $author$project$Step$String$replaceHexString = F2($author$project$Step$String$replaceHexString$);
var $author$project$Step$String$replaceX = function (_v0) {
	var match = _v0.ii;
	return $author$project$Step$String$replaceHexString$(
		2,
		$elm$core$String$dropLeft$(3, match));
};
var $author$project$Step$String$replaceX2 = function (_v0) {
	var match = _v0.ii;
	return $author$project$Step$String$replaceHexString$(
		4,
		A3($elm$core$String$slice, 4, -4, match));
};
var $author$project$Step$String$replaceX4 = function (_v0) {
	var match = _v0.ii;
	return $author$project$Step$String$replaceHexString$(
		8,
		A3($elm$core$String$slice, 4, -4, match));
};
var $author$project$Step$String$x2Regex = $elm$core$Maybe$withDefault$(
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('\\\\X2\\\\[0-9A-F]+\\\\X0\\\\'));
var $author$project$Step$String$x4Regex = $elm$core$Maybe$withDefault$(
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('\\\\X4\\\\[0-9A-F]+\\\\X0\\\\'));
var $author$project$Step$String$xRegex = $elm$core$Maybe$withDefault$(
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('\\\\X\\\\[0-9A-F]{2}'));
var $author$project$Step$String$decode = function (encodedString) {
	var string1 = A2($elm$core$String$contains, '\'\'', encodedString) ? $elm$core$String$replace$('\'\'', '\'', encodedString) : encodedString;
	return A2($elm$core$String$contains, '\\', string1) ? $elm$core$String$replace$(
		'\\\\',
		'\\',
		A3(
			$elm$regex$Regex$replace,
			$author$project$Step$String$x4Regex,
			$author$project$Step$String$replaceX4,
			A3(
				$elm$regex$Regex$replace,
				$author$project$Step$String$x2Regex,
				$author$project$Step$String$replaceX2,
				A3($elm$regex$Regex$replace, $author$project$Step$String$xRegex, $author$project$Step$String$replaceX, string1)))) : string1;
};
var $elm$core$String$toInt = _String_toInt;
var $author$project$Step$Preprocess$collectUnparsedEntities$ = function (regexMatches, accumulated, maxId) {
	collectUnparsedEntities:
	while (true) {
		if (regexMatches.b) {
			var first = regexMatches.a;
			var rest = regexMatches.b;
			var _v1 = first.fB;
			if ((((_v1.b && (!_v1.a.$)) && _v1.b.b) && (!_v1.b.a.$)) && (!_v1.b.b.b)) {
				var idString = _v1.a.a;
				var _v2 = _v1.b;
				var data = _v2.a.a;
				var _v3 = $elm$core$String$toInt(idString);
				if (!_v3.$) {
					var id = _v3.a;
					var $temp$regexMatches = rest,
						$temp$accumulated = A2(
						$elm$core$List$cons,
						_Utils_Tuple2(id, data),
						accumulated),
						$temp$maxId = $elm$core$Basics$max$(id, maxId);
					regexMatches = $temp$regexMatches;
					accumulated = $temp$accumulated;
					maxId = $temp$maxId;
					continue collectUnparsedEntities;
				} else {
					var $temp$regexMatches = rest;
					regexMatches = $temp$regexMatches;
					continue collectUnparsedEntities;
				}
			} else {
				var $temp$regexMatches = rest;
				regexMatches = $temp$regexMatches;
				continue collectUnparsedEntities;
			}
		} else {
			return _Utils_Tuple2(accumulated, maxId);
		}
	}
};
var $author$project$Step$Preprocess$collectUnparsedEntities = F3($author$project$Step$Preprocess$collectUnparsedEntities$);
var $author$project$Step$Preprocess$fillGaps$ = function (index, pairs, accumulated) {
	fillGaps:
	while (true) {
		if (pairs.b) {
			var _v1 = pairs.a;
			var id = _v1.a;
			var data = _v1.b;
			var rest = pairs.b;
			if (_Utils_eq(id, index)) {
				var $temp$index = index - 1,
					$temp$pairs = rest,
					$temp$accumulated = A2($elm$core$List$cons, data, accumulated);
				index = $temp$index;
				pairs = $temp$pairs;
				accumulated = $temp$accumulated;
				continue fillGaps;
			} else {
				var $temp$index = index - 1,
					$temp$accumulated = A2($elm$core$List$cons, '', accumulated);
				index = $temp$index;
				accumulated = $temp$accumulated;
				continue fillGaps;
			}
		} else {
			if (index >= 0) {
				var $temp$index = index - 1,
					$temp$accumulated = A2($elm$core$List$cons, '', accumulated);
				index = $temp$index;
				accumulated = $temp$accumulated;
				continue fillGaps;
			} else {
				return accumulated;
			}
		}
	}
};
var $author$project$Step$Preprocess$fillGaps = F3($author$project$Step$Preprocess$fillGaps$);
var $author$project$Step$Preprocess$nonStringChunkPattern = '[^;]+';
var $author$project$Step$Preprocess$stringChunkPattern = '\'[^\']*\'';
var $author$project$Step$Preprocess$attributeChunksPattern = '(?:(?:' + ($author$project$Step$Preprocess$stringChunkPattern + (')|(?:' + ($author$project$Step$Preprocess$nonStringChunkPattern + '))*')));
var $author$project$Step$Preprocess$entityEndPattern = '\\))\\s*;';
var $author$project$Step$Preprocess$entityStartPattern = '#(\\d+)\\s*=\\s*(\\w*\\s*\\(';
var $author$project$Step$Preprocess$simpleEntityPattern = _Utils_ap(
	$author$project$Step$Preprocess$entityStartPattern,
	_Utils_ap($author$project$Step$Preprocess$attributeChunksPattern, $author$project$Step$Preprocess$entityEndPattern));
var $author$project$Step$Preprocess$rawEntityRegex = $elm$core$Maybe$withDefault$(
	$elm$regex$Regex$never,
	A2(
		$elm$regex$Regex$fromStringWith,
		{hz: false, it: true},
		$author$project$Step$Preprocess$simpleEntityPattern));
var $author$project$Step$Preprocess$entities = function (contents) {
	var _v0 = $author$project$Step$Preprocess$collectUnparsedEntities$(
		A2($elm$regex$Regex$find, $author$project$Step$Preprocess$rawEntityRegex, contents),
		_List_Nil,
		0);
	var pairs = _v0.a;
	var maxId = _v0.b;
	var sortedPairs = A2(
		$elm$core$List$sortBy,
		A2($elm$core$Basics$composeR, $elm$core$Tuple$first, $elm$core$Basics$negate),
		pairs);
	var filled = $author$project$Step$Preprocess$fillGaps$(maxId, sortedPairs, _List_Nil);
	return $elm$core$Array$fromList(filled);
};
var $author$project$Step$Pattern$Capture = function (a) {
	return {$: 3, a: a};
};
var $author$project$Step$Pattern$capture = $author$project$Step$Pattern$Capture;
var $author$project$Step$Pattern$OneOf = function (a) {
	return {$: 2, a: a};
};
var $author$project$Step$Pattern$oneOf = $author$project$Step$Pattern$OneOf;
var $author$project$Step$Pattern$Sequence = function (a) {
	return {$: 5, a: a};
};
var $author$project$Step$Pattern$sequence = $author$project$Step$Pattern$Sequence;
var $author$project$Step$Pattern$specialCharacterRegex = $elm$core$Maybe$withDefault$(
	$elm$regex$Regex$never,
	$elm$regex$Regex$fromString('[\\\\^$.|?*+()[]'));
var $author$project$Step$Pattern$escape = function (givenString) {
	return A3(
		$elm$regex$Regex$replace,
		$author$project$Step$Pattern$specialCharacterRegex,
		function (_v0) {
			var match = _v0.ii;
			return '\\' + match;
		},
		givenString);
};
var $author$project$Step$Pattern$token = function (givenString) {
	return $author$project$Step$Pattern$Pattern(
		$author$project$Step$Pattern$escape(givenString));
};
var $author$project$Step$Pattern$whitespace = $author$project$Step$Pattern$Pattern('\\s*');
var $author$project$Step$Pattern$ZeroOrMore = function (a) {
	return {$: 6, a: a};
};
var $author$project$Step$Pattern$zeroOrMore = $author$project$Step$Pattern$ZeroOrMore;
var $author$project$Step$Pattern$list = function (item) {
	var preClosingParenthesis = $author$project$Step$Pattern$Pattern('(?=\\))');
	var repeatingPattern = $author$project$Step$Pattern$sequence(
		_List_fromArray(
			[
				$author$project$Step$Pattern$whitespace,
				item,
				$author$project$Step$Pattern$whitespace,
				$author$project$Step$Pattern$oneOf(
				_List_fromArray(
					[
						$author$project$Step$Pattern$token(','),
						preClosingParenthesis
					]))
			]));
	return $author$project$Step$Pattern$capture(
		$author$project$Step$Pattern$sequence(
			_List_fromArray(
				[
					$author$project$Step$Pattern$token('('),
					$author$project$Step$Pattern$oneOf(
					_List_fromArray(
						[
							$author$project$Step$Pattern$zeroOrMore(repeatingPattern),
							$author$project$Step$Pattern$whitespace
						])),
					$author$project$Step$Pattern$token(')')
				])));
};
var $author$project$Step$Pattern$startOfInput = $author$project$Step$Pattern$Pattern('^');
var $author$project$Step$Pattern$string = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$Pattern('\'(?:\'\'|[^\'])*\''));
var $author$project$Step$Preprocess$split = function (contents) {
	var whitespaceOrComment = $author$project$Step$Pattern$zeroOrMore(
		$author$project$Step$Pattern$oneOf(
			_List_fromArray(
				[$author$project$Step$Pattern$whitespace, $author$project$Step$Pattern$comment])));
	var stringRegex = $author$project$Step$Pattern$compile($author$project$Step$Pattern$string);
	var headerPattern = $author$project$Step$Pattern$sequence(
		$elm$core$List$intersperse$(
			whitespaceOrComment,
			_List_fromArray(
				[
					$author$project$Step$Pattern$startOfInput,
					$author$project$Step$Pattern$token('ISO-10303-21;'),
					$author$project$Step$Pattern$token('HEADER;'),
					$author$project$Step$Pattern$token('FILE_DESCRIPTION'),
					$author$project$Step$Pattern$token('('),
					$author$project$Step$Pattern$list($author$project$Step$Pattern$string),
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(')'),
					$author$project$Step$Pattern$token(';'),
					$author$project$Step$Pattern$token('FILE_NAME'),
					$author$project$Step$Pattern$token('('),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$list($author$project$Step$Pattern$string),
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$list($author$project$Step$Pattern$string),
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(','),
					$author$project$Step$Pattern$string,
					$author$project$Step$Pattern$token(')'),
					$author$project$Step$Pattern$token(';'),
					$author$project$Step$Pattern$token('FILE_SCHEMA'),
					$author$project$Step$Pattern$token('('),
					$author$project$Step$Pattern$list($author$project$Step$Pattern$string),
					$author$project$Step$Pattern$token(')'),
					$author$project$Step$Pattern$token(';'),
					$author$project$Step$Pattern$token('ENDSEC;'),
					$author$project$Step$Pattern$token('DATA;')
				])));
	var headerRegex = $author$project$Step$Pattern$compile(headerPattern);
	var decode = function (rawString) {
		return $author$project$Step$String$decode(
			A3($elm$core$String$slice, 1, -1, rawString));
	};
	var decodeList = function (rawString) {
		return $elm$core$List$map$(
			A2(
				$elm$core$Basics$composeR,
				function ($) {
					return $.ii;
				},
				decode),
			A2($elm$regex$Regex$find, stringRegex, rawString));
	};
	var _v0 = A2($elm$regex$Regex$find, headerRegex, contents);
	if (_v0.b && (!_v0.b.b)) {
		var submatches = _v0.a.fB;
		var match = _v0.a.ii;
		if ((((((((((((((((((((submatches.b && (!submatches.a.$)) && submatches.b.b) && (!submatches.b.a.$)) && submatches.b.b.b) && (!submatches.b.b.a.$)) && submatches.b.b.b.b) && (!submatches.b.b.b.a.$)) && submatches.b.b.b.b.b) && (!submatches.b.b.b.b.a.$)) && submatches.b.b.b.b.b.b) && (!submatches.b.b.b.b.b.a.$)) && submatches.b.b.b.b.b.b.b) && (!submatches.b.b.b.b.b.b.a.$)) && submatches.b.b.b.b.b.b.b.b) && (!submatches.b.b.b.b.b.b.b.a.$)) && submatches.b.b.b.b.b.b.b.b.b) && (!submatches.b.b.b.b.b.b.b.b.a.$)) && submatches.b.b.b.b.b.b.b.b.b.b) && (!submatches.b.b.b.b.b.b.b.b.b.a.$)) && (!submatches.b.b.b.b.b.b.b.b.b.b.b)) {
			var description = submatches.a.a;
			var _v2 = submatches.b;
			var implementationLevel = _v2.a.a;
			var _v3 = _v2.b;
			var fileName = _v3.a.a;
			var _v4 = _v3.b;
			var timeStamp = _v4.a.a;
			var _v5 = _v4.b;
			var author = _v5.a.a;
			var _v6 = _v5.b;
			var organization = _v6.a.a;
			var _v7 = _v6.b;
			var preprocessorVersion = _v7.a.a;
			var _v8 = _v7.b;
			var originatingSystem = _v8.a.a;
			var _v9 = _v8.b;
			var authorization = _v9.a.a;
			var _v10 = _v9.b;
			var schemaIdentifiers = _v10.a.a;
			return $elm$core$Maybe$Just(
				_Utils_Tuple2(
					{
						ho: decodeList(author),
						hp: decode(authorization),
						hO: decodeList(description),
						hX: decode(fileName),
						h7: decode(implementationLevel),
						iI: decodeList(organization),
						iJ: decode(originatingSystem),
						iP: decode(preprocessorVersion),
						iY: decodeList(schemaIdentifiers),
						jx: decode(timeStamp)
					},
					$author$project$Step$Preprocess$entities(
						$elm$core$String$dropLeft$(
							$elm$core$String$length(match),
							contents))));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Step$Decode$parse = function (contents) {
	var _v0 = $author$project$Step$Preprocess$split(contents);
	if (!_v0.$) {
		var _v1 = _v0.a;
		var parsedHeader = _v1.a;
		var entityLines = _v1.b;
		return $elm$core$Result$Ok(
			$author$project$Step$Decode$File$(parsedHeader, entityLines));
	} else {
		return $elm$core$Result$Err('Failed to parse STEP file header');
	}
};
var $author$project$StepImport$FeaturePiece = function (a) {
	return {$: 1, a: a};
};
var $author$project$StepImport$FlatPiece = function (a) {
	return {$: 0, a: a};
};
var $author$project$StepImport$Vec$ = function (x, y, z) {
	return {m: x, n: y, o: z};
};
var $author$project$StepImport$Vec = F3($author$project$StepImport$Vec$);
var $author$project$StepImport$add$ = function (a, b) {
	return {m: a.m + b.m, n: a.n + b.n, o: a.o + b.o};
};
var $author$project$StepImport$add = F2($author$project$StepImport$add$);
var $author$project$StepImport$dot$ = function (a, b) {
	return ((a.m * b.m) + (a.n * b.n)) + (a.o * b.o);
};
var $author$project$StepImport$dot = F2($author$project$StepImport$dot$);
var $author$project$StepImport$angleTolerance = 1.0e-6;
var $author$project$StepImport$cross$ = function (a, b) {
	return {m: (a.n * b.o) - (a.o * b.n), n: (a.o * b.m) - (a.m * b.o), o: (a.m * b.n) - (a.n * b.m)};
};
var $author$project$StepImport$cross = F2($author$project$StepImport$cross$);
var $author$project$StepImport$lengthOf = function (a) {
	return $elm$core$Basics$sqrt(
		$author$project$StepImport$dot$(a, a));
};
var $author$project$StepImport$sub$ = function (a, b) {
	return {m: a.m - b.m, n: a.n - b.n, o: a.o - b.o};
};
var $author$project$StepImport$sub = F2($author$project$StepImport$sub$);
var $author$project$StepImport$distance$ = function (a, b) {
	return $author$project$StepImport$lengthOf(
		$author$project$StepImport$sub$(a, b));
};
var $author$project$StepImport$distance = F2($author$project$StepImport$distance$);
var $author$project$StepImport$scale$ = function (s, a) {
	return {m: s * a.m, n: s * a.n, o: s * a.o};
};
var $author$project$StepImport$scale = F2($author$project$StepImport$scale$);
var $author$project$StepImport$normalize = function (a) {
	var l = $author$project$StepImport$lengthOf(a);
	return (l > 0) ? $author$project$StepImport$scale$(1 / l, a) : a;
};
var $ianmackenzie$elm_geometry$Point2d$unsafe = function (coordinates) {
	return coordinates;
};
var $author$project$StepImport$point2d = function (_v0) {
	var x = _v0.a;
	var y = _v0.b;
	return $ianmackenzie$elm_geometry$Point2d$unsafe(
		{m: x, n: y});
};
var $author$project$StepImport$positiveAngle = function (angle) {
	var wrapped = angle - ((2 * $elm$core$Basics$pi) * $elm$core$Basics$floor(angle / (2 * $elm$core$Basics$pi)));
	return (wrapped < 1.0e-9) ? (2 * $elm$core$Basics$pi) : wrapped;
};
var $author$project$StepImport$rotateAround$ = function (center, axis, angle, p) {
	var d = $author$project$StepImport$sub$(p, center);
	var along = $author$project$StepImport$scale$(
		$author$project$StepImport$dot$(d, axis),
		axis);
	var across = $author$project$StepImport$sub$(d, along);
	return $author$project$StepImport$add$(
		center,
		$author$project$StepImport$add$(
			along,
			$author$project$StepImport$add$(
				$author$project$StepImport$scale$(
					$elm$core$Basics$cos(angle),
					across),
				$author$project$StepImport$scale$(
					$elm$core$Basics$sin(angle),
					$author$project$StepImport$cross$(axis, across)))));
};
var $author$project$StepImport$rotateAround = F4($author$project$StepImport$rotateAround$);
var $author$project$StepImport$reverseRun = function (run) {
	return _Utils_update(
		run,
		{f_: run.fz, bi: !run.bi, fz: run.f_});
};
var $author$project$StepImport$runsOf = function (bound_) {
	var runs = $elm$core$List$map$(
		function (_v0) {
			var edge = _v0.a;
			var sameSense = _v0.b;
			return sameSense ? {t: edge.t, f_: edge.f_, bi: edge.Y, bX: edge.bX, fz: edge.fz} : {t: edge.t, f_: edge.fz, bi: !edge.Y, bX: edge.bX, fz: edge.f_};
		},
		bound_.bS);
	return bound_.Y ? runs : $elm$core$List$map$(
		$author$project$StepImport$reverseRun,
		$elm$core$List$reverse(runs));
};
var $author$project$StepImport$sweptAround$ = function (center, axis, run) {
	var b = $author$project$StepImport$sub$(run.f_, center);
	var a = $author$project$StepImport$sub$(run.fz, center);
	var ccw = $author$project$StepImport$positiveAngle(
		A2(
			$elm$core$Basics$atan2,
			$author$project$StepImport$dot$(
				axis,
				$author$project$StepImport$cross$(a, b)),
			$author$project$StepImport$dot$(a, b)));
	var cw = $author$project$StepImport$positiveAngle(
		A2(
			$elm$core$Basics$atan2,
			$author$project$StepImport$dot$(
				axis,
				$author$project$StepImport$cross$(b, a)),
			$author$project$StepImport$dot$(a, b)));
	return run.bi ? ccw : (-cw);
};
var $author$project$StepImport$sweptAround = F3($author$project$StepImport$sweptAround$);
var $author$project$StepImport$tolerance = 1.0e-6;
var $author$project$StepImport$featureOf$ = function (frame, outward, bounds) {
	var runs = $elm$core$List$filter$(
		function (run) {
			return (_Utils_cmp(
				$author$project$StepImport$distance$(run.fz, run.f_),
				$author$project$StepImport$tolerance) > 0) || (!_Utils_eq(run.t, $author$project$StepImport$LineCurve));
		},
		$elm$core$List$concatMap$($author$project$StepImport$runsOf, bounds));
	var relative = function (p) {
		return $author$project$StepImport$sub$(p, frame.z);
	};
	var axis = frame.w;
	var radial = function (p) {
		var d = relative(p);
		return $author$project$StepImport$sub$(
			d,
			$author$project$StepImport$scale$(
				$author$project$StepImport$dot$(d, axis),
				axis));
	};
	var offAxis = function (p) {
		return $author$project$StepImport$lengthOf(
			radial(p));
	};
	var isMeridian = function (run) {
		var far = (_Utils_cmp(
			offAxis(run.fz),
			offAxis(run.f_)) > 0) ? run.fz : run.f_;
		if (_Utils_cmp(
			offAxis(far),
			$author$project$StepImport$tolerance) < 0) {
			return false;
		} else {
			var planeNormal = $author$project$StepImport$normalize(
				$author$project$StepImport$cross$(
					axis,
					radial(far)));
			var inPlane = function (p) {
				return (_Utils_cmp(
					$elm$core$Basics$abs(
						$author$project$StepImport$dot$(
							relative(p),
							planeNormal)),
					$author$project$StepImport$tolerance) < 0) && (_Utils_cmp(
					$author$project$StepImport$dot$(
						radial(p),
						radial(far)),
					-$author$project$StepImport$tolerance) > -1);
			};
			return inPlane(run.fz) && (inPlane(run.f_) && function () {
				var _v12 = run.t;
				if (!_v12.$) {
					return true;
				} else {
					var circle = _v12.a;
					return inPlane(circle.H.z) && (_Utils_cmp(
						$author$project$StepImport$lengthOf(
							$author$project$StepImport$cross$(
								$author$project$StepImport$normalize(
									$elm$core$Maybe$withDefault$(planeNormal, circle.H.w)),
								planeNormal)),
						$author$project$StepImport$angleTolerance) < 0);
				}
			}());
		}
	};
	var meridians = $elm$core$List$filter$(isMeridian, runs);
	var isParallel = function (run) {
		var _v11 = run.t;
		if (_v11.$ === 1) {
			var circle = _v11.a;
			return (_Utils_cmp(
				$author$project$StepImport$lengthOf(
					$author$project$StepImport$cross$(
						$author$project$StepImport$normalize(
							$elm$core$Maybe$withDefault$(axis, circle.H.w)),
						axis)),
				$author$project$StepImport$angleTolerance) < 0) && (_Utils_cmp(
				offAxis(circle.H.z),
				$author$project$StepImport$tolerance) < 0);
		} else {
			return false;
		}
	};
	var parallels = $elm$core$List$filter$(isParallel, runs);
	var stray = $elm$core$List$filter$(
		function (run) {
			return (!isParallel(run)) && (!isMeridian(run));
		},
		runs);
	var profilePoint = function (p) {
		return _Utils_Tuple2(
			$author$project$StepImport$lengthOf(
				radial(p)),
			$author$project$StepImport$dot$(
				relative(p),
				axis));
	};
	var profile = function () {
		if (meridians.b) {
			var run = meridians.a;
			var toProfile = function (p) {
				return $author$project$StepImport$point2d(
					profilePoint(p));
			};
			var segments = F2(
				function (start, rest) {
					return $elm$core$List$foldl$(
						F2(
							function (_v8, _v9) {
								var end = _v8.a;
								var center = _v8.b;
								var acc = _v9.b;
								return _Utils_Tuple2(
									end,
									_Utils_ap(
										acc,
										_List_fromArray(
											[
												function () {
												if (!center.$) {
													var c = center.a;
													return $author$project$Surface$Circle(
														{
															b: toProfile(c),
															f_: toProfile(end)
														});
												} else {
													return $author$project$Surface$Line(
														{
															f_: toProfile(end)
														});
												}
											}()
											])));
							}),
						_Utils_Tuple2(start, _List_Nil),
						rest).b;
				});
			var points = function () {
				var _v7 = run.t;
				if (!_v7.$) {
					return _List_fromArray(
						[
							_Utils_Tuple2(run.f_, $elm$core$Maybe$Nothing)
						]);
				} else {
					var circle = _v7.a;
					var circleAxis = $author$project$StepImport$normalize(
						$elm$core$Maybe$withDefault$(axis, circle.H.w));
					var center = circle.H.z;
					var swept = $author$project$StepImport$sweptAround$(center, circleAxis, run);
					return (_Utils_cmp(
						$elm$core$Basics$abs(swept),
						0.99 * $elm$core$Basics$pi) > 0) ? _List_fromArray(
						[
							_Utils_Tuple2(
							$author$project$StepImport$rotateAround$(center, circleAxis, swept / 2, run.fz),
							$elm$core$Maybe$Just(center)),
							_Utils_Tuple2(
							run.f_,
							$elm$core$Maybe$Just(center))
						]) : _List_fromArray(
						[
							_Utils_Tuple2(
							run.f_,
							$elm$core$Maybe$Just(center))
						]);
				}
			}();
			var _v5 = function () {
				var _v6 = run.t;
				if (!_v6.$) {
					return _Utils_Tuple2(
						$author$project$StepImport$scale$(
							0.5,
							$author$project$StepImport$add$(run.fz, run.f_)),
						$author$project$StepImport$sub$(run.f_, run.fz));
				} else {
					var circle = _v6.a;
					var circleAxis = $author$project$StepImport$normalize(
						$elm$core$Maybe$withDefault$(axis, circle.H.w));
					var swept = $author$project$StepImport$sweptAround$(circle.H.z, circleAxis, run);
					var m = $author$project$StepImport$rotateAround$(circle.H.z, circleAxis, swept / 2, run.fz);
					return _Utils_Tuple2(
						m,
						$author$project$StepImport$scale$(
							swept,
							$author$project$StepImport$cross$(
								circleAxis,
								$author$project$StepImport$sub$(m, circle.H.z))));
				}
			}();
			var middle = _v5.a;
			var tangent = _v5.b;
			var n = outward(middle);
			var out = $author$project$StepImport$normalize(
				radial(middle));
			var rightWay = (($author$project$StepImport$dot$(tangent, axis) * $author$project$StepImport$dot$(n, out)) - ($author$project$StepImport$dot$(tangent, out) * $author$project$StepImport$dot$(n, axis))) >= 0;
			if (rightWay) {
				return $elm$core$Result$Ok(
					{
						gX: A2(segments, run.fz, points),
						fz: toProfile(run.fz)
					});
			} else {
				var nodes = A2(
					$elm$core$List$cons,
					run.fz,
					$elm$core$List$map$($elm$core$Tuple$first, points));
				var centers = $elm$core$List$map$($elm$core$Tuple$second, points);
				var reversedPoints = A3(
					$elm$core$List$map2,
					$elm$core$Tuple$pair,
					$elm$core$List$drop$(
						1,
						$elm$core$List$reverse(nodes)),
					$elm$core$List$reverse(centers));
				return $elm$core$Result$Ok(
					{
						gX: A2(segments, run.f_, reversedPoints),
						fz: toProfile(run.f_)
					});
			}
		} else {
			return $elm$core$Result$Err('none of its edges go along its axis, so its profile isn\'t known');
		}
	}();
	var y = $author$project$StepImport$cross$(axis, frame.m);
	var theta = function (p) {
		return A2(
			$elm$core$Basics$atan2,
			$author$project$StepImport$dot$(
				relative(p),
				y),
			$author$project$StepImport$dot$(
				relative(p),
				frame.m));
	};
	var sweep = function () {
		if (parallels.b) {
			var run = parallels.a;
			if (_Utils_cmp(
				$author$project$StepImport$distance$(run.fz, run.f_),
				$author$project$StepImport$tolerance) < 0) {
				return $elm$core$Result$Ok($author$project$Surface$FullTurn);
			} else {
				var circleAxis = function () {
					var _v3 = run.t;
					if (_v3.$ === 1) {
						var circle = _v3.a;
						return $elm$core$Maybe$withDefault$(axis, circle.H.w);
					} else {
						return axis;
					}
				}();
				var around = _Utils_eq(
					run.bi,
					$author$project$StepImport$dot$(circleAxis, axis) > 0) ? 1 : (-1);
				var _v2 = (around > 0) ? _Utils_Tuple2(
					theta(run.fz),
					theta(run.f_)) : _Utils_Tuple2(
					theta(run.f_),
					theta(run.fz));
				var from = _v2.a;
				var to = _v2.b;
				return $elm$core$Result$Ok(
					$author$project$Surface$PartTurn(
						{
							c: $ianmackenzie$elm_units$Angle$radians(from),
							e: $ianmackenzie$elm_units$Angle$radians(
								from + $author$project$StepImport$positiveAngle(to - from))
						}));
			}
		} else {
			return $elm$core$Result$Err('none of its edges go around its axis, so how far round it goes isn\'t known');
		}
	}();
	if (stray.b) {
		var run = stray.a;
		return $elm$core$Result$Err(
			'edge #' + ($elm$core$String$fromInt(run.bX) + ' neither goes around its axis nor along it (two fillets meeting at a sharp corner make edges like this)'));
	} else {
		return $elm$core$Result$map2$(
			F2(
				function (sweep_, profile_) {
					return {
						h_: $ianmackenzie$elm_geometry$Frame3d$unsafe(
							{
								gK: $ianmackenzie$elm_geometry$Point3d$fromMeters(frame.z),
								g6: $ianmackenzie$elm_geometry$Direction3d$unsafe(frame.m),
								g7: $ianmackenzie$elm_geometry$Direction3d$unsafe(y),
								jO: $ianmackenzie$elm_geometry$Direction3d$unsafe(axis)
							}),
						u: profile_,
						jg: sweep_
					};
				}),
			sweep,
			profile);
	}
};
var $author$project$StepImport$featureOf = F3($author$project$StepImport$featureOf$);
var $elm$core$List$sum = function (numbers) {
	return $elm$core$List$foldl$($elm$core$Basics$add, 0, numbers);
};
var $author$project$StepImport$signedArea = function (points) {
	return 0.5 * $elm$core$List$sum(
		A3(
			$elm$core$List$map2,
			F2(
				function (_v0, _v1) {
					var x0 = _v0.a;
					var y0 = _v0.b;
					var x1 = _v1.a;
					var y1 = _v1.b;
					return (x0 * y1) - (x1 * y0);
				}),
			points,
			_Utils_ap(
				$elm$core$List$drop$(1, points),
				$elm$core$List$take$(1, points))));
};
var $author$project$StepImport$flatOf$ = function (frame, sense, bounds) {
	var x = frame.m;
	var oriented = F2(
		function (wantPositive, loop) {
			return _Utils_eq(loop.eH > 0, wantPositive) ? loop.fs : $elm$core$List$map$(
				$author$project$StepImport$reverseRun,
				$elm$core$List$reverse(loop.fs));
		});
	var normal = $author$project$StepImport$scale$(sense, frame.w);
	var y = $author$project$StepImport$cross$(normal, x);
	var to2d = function (p) {
		var d = $author$project$StepImport$sub$(p, frame.z);
		return _Utils_Tuple2(
			$author$project$StepImport$dot$(d, x),
			$author$project$StepImport$dot$(d, y));
	};
	var edgeOf = function (run) {
		var _v2 = run.t;
		if (!_v2.$) {
			return {
				dV: $author$project$Surface$Straight(
					$author$project$StepImport$point2d(
						to2d(run.fz))),
				iX: _List_fromArray(
					[
						to2d(run.fz)
					]),
				fz: to2d(run.fz)
			};
		} else {
			var circle = _v2.a;
			var center = circle.H.z;
			var axis = $author$project$StepImport$normalize(
				$elm$core$Maybe$withDefault$(normal, circle.H.w));
			var swept = $author$project$StepImport$sweptAround$(center, axis, run) * (($author$project$StepImport$dot$(axis, normal) < 0) ? (-1) : 1);
			var _v3 = to2d(run.fz);
			var sx = _v3.a;
			var sy = _v3.b;
			var _v4 = to2d(center);
			var cx = _v4.a;
			var cy = _v4.b;
			var a0 = A2($elm$core$Basics$atan2, sy - cy, sx - cx);
			var r = $elm$core$Basics$sqrt(
				A2($elm$core$Basics$pow, sx - cx, 2) + A2($elm$core$Basics$pow, sy - cy, 2));
			return {
				dV: $author$project$Surface$Arc(
					{
						b: $author$project$StepImport$point2d(
							_Utils_Tuple2(cx, cy)),
						fz: $author$project$StepImport$point2d(
							_Utils_Tuple2(sx, sy)),
						jh: $ianmackenzie$elm_units$Angle$radians(swept)
					}),
				iX: $elm$core$List$map$(
					function (i) {
						return function (a) {
							return _Utils_Tuple2(
								cx + (r * $elm$core$Basics$cos(a)),
								cy + (r * $elm$core$Basics$sin(a)));
						}(a0 + ((swept * i) / 16));
					},
					$elm$core$List$range$(0, 15)),
				fz: _Utils_Tuple2(sx, sy)
			};
		}
	};
	var loops = $elm$core$List$map$(
		function (bound_) {
			var runs = $author$project$StepImport$runsOf(bound_);
			return {
				eH: $author$project$StepImport$signedArea(
					$elm$core$List$concatMap$(
						A2(
							$elm$core$Basics$composeR,
							edgeOf,
							function ($) {
								return $.iX;
							}),
						runs)),
				b0: bound_.b0,
				fs: runs
			};
		},
		bounds);
	var outer = function () {
		var _v1 = $elm$core$List$filter$(
			function ($) {
				return $.b0;
			},
			loops);
		if (_v1.b) {
			var first = _v1.a;
			return $elm$core$Maybe$Just(first);
		} else {
			return $elm$core$List$head(
				A2(
					$elm$core$List$sortBy,
					A2(
						$elm$core$Basics$composeR,
						function ($) {
							return $.eH;
						},
						A2($elm$core$Basics$composeR, $elm$core$Basics$abs, $elm$core$Basics$negate)),
					loops));
		}
	}();
	if (!outer.$) {
		var outer_ = outer.a;
		return $elm$core$Result$Ok(
			{
				eM: A2(
					$elm$core$List$cons,
					$elm$core$List$map$(
						A2(
							$elm$core$Basics$composeR,
							edgeOf,
							function ($) {
								return $.dV;
							}),
						A2(oriented, true, outer_)),
					$elm$core$List$map$(
						A2(
							$elm$core$Basics$composeR,
							oriented(false),
							$elm$core$List$map(
								A2(
									$elm$core$Basics$composeR,
									edgeOf,
									function ($) {
										return $.dV;
									}))),
						$elm$core$List$filter$(
							function (loop) {
								return !_Utils_eq(loop, outer_);
							},
							loops))),
				iO: $ianmackenzie$elm_geometry$SketchPlane3d$unsafe(
					{
						gK: $ianmackenzie$elm_geometry$Point3d$fromMeters(frame.z),
						g6: $ianmackenzie$elm_geometry$Direction3d$unsafe(x),
						g7: $ianmackenzie$elm_geometry$Direction3d$unsafe(y)
					})
			});
	} else {
		return $elm$core$Result$Err('a plane with no edges');
	}
};
var $author$project$StepImport$flatOf = F3($author$project$StepImport$flatOf$);
var $author$project$StepImport$perpendicularTo = function (v) {
	return ($elm$core$Basics$abs(v.m) < 0.9) ? $author$project$StepImport$normalize(
		$author$project$StepImport$cross$(
			v,
			$author$project$StepImport$Vec$(1, 0, 0))) : $author$project$StepImport$normalize(
		$author$project$StepImport$cross$(
			v,
			$author$project$StepImport$Vec$(0, 1, 0)));
};
var $elm$core$List$singleton = function (value) {
	return _List_fromArray(
		[value]);
};
var $author$project$StepImport$pieceOf = function (face_) {
	var sense = face_.Y ? 1 : (-1);
	var radialFrom = F2(
		function (frame, p) {
			var d = $author$project$StepImport$sub$(p, frame.z);
			return $author$project$StepImport$sub$(
				d,
				$author$project$StepImport$scale$(
					$author$project$StepImport$dot$(d, frame.w),
					frame.w));
		});
	var frameOf = function (p) {
		var axis = $author$project$StepImport$normalize(
			$elm$core$Maybe$withDefault$(
				$author$project$StepImport$Vec$(0, 0, 1),
				p.w));
		var ref = $elm$core$Maybe$withDefault$(
			$author$project$StepImport$perpendicularTo(axis),
			p.cB);
		var x = $author$project$StepImport$normalize(
			$author$project$StepImport$sub$(
				ref,
				$author$project$StepImport$scale$(
					$author$project$StepImport$dot$(ref, axis),
					axis)));
		return {w: axis, z: p.z, m: x};
	};
	var _v0 = face_.bT;
	switch (_v0.$) {
		case 0:
			var p = _v0.a;
			return $elm$core$Result$map$(
				$author$project$StepImport$FlatPiece,
				$author$project$StepImport$flatOf$(
					frameOf(p),
					sense,
					face_.at));
		case 1:
			var p = _v0.a;
			var frame = frameOf(p);
			return $elm$core$Result$map$(
				$author$project$StepImport$FeaturePiece,
				$author$project$StepImport$featureOf$(
					frame,
					function (q) {
						return $author$project$StepImport$scale$(
							sense,
							$author$project$StepImport$normalize(
								A2(radialFrom, frame, q)));
					},
					face_.at));
		case 2:
			var p = _v0.a;
			var semiAngle = _v0.c;
			var frame = frameOf(p);
			return $elm$core$Result$map$(
				$author$project$StepImport$FeaturePiece,
				$author$project$StepImport$featureOf$(
					frame,
					function (q) {
						return $author$project$StepImport$scale$(
							sense,
							$author$project$StepImport$normalize(
								$author$project$StepImport$sub$(
									$author$project$StepImport$normalize(
										A2(radialFrom, frame, q)),
									$author$project$StepImport$scale$(
										$elm$core$Basics$tan(semiAngle),
										frame.w))));
					},
					face_.at));
		case 4:
			var p = _v0.a;
			var major = _v0.b;
			var frame = frameOf(p);
			return $elm$core$Result$map$(
				$author$project$StepImport$FeaturePiece,
				$author$project$StepImport$featureOf$(
					frame,
					function (q) {
						return $author$project$StepImport$scale$(
							sense,
							$author$project$StepImport$normalize(
								$author$project$StepImport$sub$(
									q,
									$author$project$StepImport$add$(
										frame.z,
										$author$project$StepImport$scale$(
											major,
											$author$project$StepImport$normalize(
												A2(radialFrom, frame, q)))))));
					},
					face_.at));
		default:
			var p = _v0.a;
			var outward = function (q) {
				return $author$project$StepImport$scale$(
					sense,
					$author$project$StepImport$normalize(
						$author$project$StepImport$sub$(q, p.z)));
			};
			var tryAxes = function (axes) {
				tryAxes:
				while (true) {
					if (axes.b) {
						var axis = axes.a;
						var rest = axes.b;
						var _v2 = $author$project$StepImport$featureOf$(
							frameOf(
								_Utils_update(
									p,
									{
										w: $elm$core$Maybe$Just(axis)
									})),
							outward,
							face_.at);
						if (!_v2.$) {
							var feature = _v2.a;
							return $elm$core$Result$Ok(feature);
						} else {
							var error = _v2.a;
							if ($elm$core$List$isEmpty(rest)) {
								return $elm$core$Result$Err(error);
							} else {
								var $temp$axes = rest;
								axes = $temp$axes;
								continue tryAxes;
							}
						}
					} else {
						return $elm$core$Result$Err('a sphere with no edges');
					}
				}
			};
			var circleAxes = $elm$core$List$filterMap$(
				function (run) {
					var _v3 = run.t;
					if (_v3.$ === 1) {
						var circle = _v3.a;
						return circle.H.w;
					} else {
						return $elm$core$Maybe$Nothing;
					}
				},
				$elm$core$List$concatMap$($author$project$StepImport$runsOf, face_.at));
			return $elm$core$Result$map$(
				$author$project$StepImport$FeaturePiece,
				tryAxes(
					_Utils_ap(
						$elm$core$Maybe$withDefault$(
							_List_Nil,
							$elm$core$Maybe$map$($elm$core$List$singleton, p.w)),
						circleAxes)));
	}
};
var $author$project$Step$Decode$Decoder$ = function (a, b) {
	return {$: 0, a: a, b: b};
};
var $author$project$Step$Decode$Decoder = F2($author$project$Step$Decode$Decoder$);
var $author$project$Step$Pattern$bool = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$Pattern('\\.[TF]\\.'));
var $author$project$Step$Decode$couldNotParseAttributeAs = function (dataType) {
	return $author$project$Step$Decode$errorMessage('Could not parse attribute as ' + dataType);
};
var $author$project$Step$Decode$bool = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$bool,
	F2(
		function (_v0, submatches) {
			if (submatches.b) {
				if (!submatches.a.$) {
					var submatch = submatches.a.a;
					var rest = submatches.b;
					return $author$project$Step$Decode$Succeeded$(submatch === '.T.', rest);
				} else {
					var _v2 = submatches.a;
					return $author$project$Step$Decode$couldNotParseAttributeAs('bool');
				}
			} else {
				return $author$project$Step$Decode$wrongNumberOfSubmatches;
			}
		}));
var $author$project$Step$Decode$ignore = function (attributeDecoder) {
	var _v0 = attributeDecoder;
	var pattern = _v0.a;
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$capture(pattern),
		F2(
			function (_v1, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						var remaining = submatches.b;
						return $author$project$Step$Decode$Succeeded$($elm$core$Basics$identity, remaining);
					} else {
						var _v3 = submatches.a;
						return $author$project$Step$Decode$errorMessage('Could not parse ignored attribute');
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$Step$Decode$ignoreContext = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$startOfInput,
	F2(
		function (_v0, submatches) {
			return $author$project$Step$Decode$Succeeded$($elm$core$Basics$identity, submatches);
		}));
var $author$project$Step$Decode$ignoreId = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$startOfInput,
	F2(
		function (_v0, submatches) {
			return $author$project$Step$Decode$Succeeded$($elm$core$Basics$identity, submatches);
		}));
var $author$project$Step$Decode$unexpectedTypeFromAttribute = $author$project$Step$Decode$internalError('attribute decoder returned UnexpectedType');
var $author$project$Step$Decode$keep = function (attributeDecoder) {
	var _v0 = attributeDecoder;
	var pattern = _v0.a;
	var chompAttribute = _v0.b;
	return $author$project$Step$Decode$Decoder$(
		pattern,
		F2(
			function (entityLine, submatches) {
				var _v1 = A2(chompAttribute, entityLine, submatches);
				switch (_v1.$) {
					case 0:
						var value = _v1.a;
						var remaining = _v1.b;
						return $author$project$Step$Decode$Succeeded$(
							$elm$core$Basics$apR(value),
							remaining);
					case 1:
						var error = _v1.a;
						return $author$project$Step$Decode$Failed(error);
					default:
						return $author$project$Step$Decode$unexpectedTypeFromAttribute;
				}
			}));
};
var $author$project$Step$Pattern$endOfInput = $author$project$Step$Pattern$Pattern('$');
var $author$project$Step$Decode$listHelp$ = function (chompItem, entityLine, matches, accumulated, remainingSubmatches) {
	listHelp:
	while (true) {
		if (matches.b) {
			var submatches = matches.a.fB;
			var rest = matches.b;
			var _v1 = A2(chompItem, entityLine, submatches);
			switch (_v1.$) {
				case 0:
					if (!_v1.b.b) {
						var item = _v1.a;
						var $temp$matches = rest,
							$temp$accumulated = A2($elm$core$List$cons, item, accumulated);
						matches = $temp$matches;
						accumulated = $temp$accumulated;
						continue listHelp;
					} else {
						var _v2 = _v1.b;
						return $author$project$Step$Decode$wrongNumberOfSubmatches;
					}
				case 1:
					var error = _v1.a;
					return $author$project$Step$Decode$Failed(error);
				default:
					return $author$project$Step$Decode$unexpectedTypeFromAttribute;
			}
		} else {
			return $author$project$Step$Decode$Succeeded$(
				$elm$core$List$reverse(accumulated),
				remainingSubmatches);
		}
	}
};
var $author$project$Step$Decode$listHelp = F5($author$project$Step$Decode$listHelp$);
var $author$project$Step$Decode$list = function (itemDecoder) {
	var _v0 = itemDecoder;
	var itemPattern = _v0.a;
	var chompItem = _v0.b;
	var searchPattern = $author$project$Step$Pattern$sequence(
		_List_fromArray(
			[
				$author$project$Step$Pattern$whitespace,
				itemPattern,
				$author$project$Step$Pattern$whitespace,
				$author$project$Step$Pattern$oneOf(
				_List_fromArray(
					[
						$author$project$Step$Pattern$token(','),
						$author$project$Step$Pattern$endOfInput
					]))
			]));
	var searchRegex = $author$project$Step$Pattern$compile(searchPattern);
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$list(itemPattern),
		F2(
			function (entityLine, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						var listString = submatches.a.a;
						var rest = submatches.b;
						return $author$project$Step$Decode$listHelp$(
							chompItem,
							entityLine,
							A2(
								$elm$regex$Regex$find,
								searchRegex,
								A3($elm$core$String$slice, 1, -1, listString)),
							_List_Nil,
							rest);
					} else {
						var _v2 = submatches.a;
						return $author$project$Step$Decode$couldNotParseAttributeAs('list');
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$Step$Pattern$derivedValue = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$token('*'));
var $author$project$Step$Decode$derivedValue = function (result) {
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$derivedValue,
		F2(
			function (_v0, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						var rest = submatches.b;
						return $author$project$Step$Decode$Succeeded$(result, rest);
					} else {
						var _v2 = submatches.a;
						return $author$project$Step$Decode$couldNotParseAttributeAs('derived value (*)');
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$StepImport$Edge$ = function (id, start, end, curve, sameSense) {
	return {t: curve, f_: end, bX: id, Y: sameSense, fz: start};
};
var $author$project$StepImport$Edge = F5($author$project$StepImport$Edge$);
var $author$project$Step$Pattern$enum = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$Pattern('\\.\\w+\\.'));
var $elm$core$String$toUpper = _String_toUpper;
var $author$project$Step$Decode$enum = function (cases) {
	var normalized = $elm$core$List$map$(
		$elm$core$Tuple$mapFirst($elm$core$String$toUpper),
		cases);
	var lookupDict = $elm$core$Dict$fromList(normalized);
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$enum,
		F2(
			function (_v0, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						var enumString = submatches.a.a;
						var remaining = submatches.b;
						var _v2 = $elm$core$Dict$get$(
							A3($elm$core$String$slice, 1, -1, enumString),
							lookupDict);
						if (!_v2.$) {
							var value = _v2.a;
							return $author$project$Step$Decode$Succeeded$(value, remaining);
						} else {
							return $author$project$Step$Decode$errorMessage('unexpected enum value \'' + (enumString + '\''));
						}
					} else {
						var _v3 = submatches.a;
						return $author$project$Step$Decode$couldNotParseAttributeAs('enum');
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$Step$Pattern$float = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$Pattern('[-+]?\\d+\\.\\d*(?:E[-+]?\\d+)?'));
var $elm$core$String$toFloat = _String_toFloat;
var $author$project$Step$Decode$float = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$float,
	F2(
		function (_v0, submatches) {
			if (submatches.b) {
				if (!submatches.a.$) {
					var floatString = submatches.a.a;
					var rest = submatches.b;
					var _v2 = $elm$core$String$toFloat(floatString);
					if (!_v2.$) {
						var floatValue = _v2.a;
						return $author$project$Step$Decode$Succeeded$(floatValue, rest);
					} else {
						return $author$project$Step$Decode$internalError('could not parse \'' + (floatString + '\' as a real number'));
					}
				} else {
					var _v3 = submatches.a;
					return $author$project$Step$Decode$couldNotParseAttributeAs('float');
				}
			} else {
				return $author$project$Step$Decode$wrongNumberOfSubmatches;
			}
		}));
var $author$project$Step$Decode$makeEntityDecoder = function (chomp) {
	return $author$project$Step$Decode$Decoder$($author$project$Step$Pattern$startOfInput, chomp);
};
var $author$project$Step$Decode$lazy = function (constructor) {
	return $author$project$Step$Decode$makeEntityDecoder(
		F2(
			function (entityLine, submatches) {
				var _v0 = constructor(0);
				var actualChomp = _v0.b;
				return A2(actualChomp, entityLine, submatches);
			}));
};
var $author$project$Step$Decode$chompOneOf$ = function (entityDecoders, entityLine, _v0) {
	chompOneOf:
	while (true) {
		if (entityDecoders.b) {
			var first = entityDecoders.a;
			var rest = entityDecoders.b;
			var _v2 = $author$project$Step$Decode$decodeEntity$(first, entityLine);
			switch (_v2.$) {
				case 0:
					var value = _v2.a;
					return $author$project$Step$Decode$Succeeded$(value, _List_Nil);
				case 2:
					var $temp$entityDecoders = rest,
						$temp$_v0 = _List_Nil;
					entityDecoders = $temp$entityDecoders;
					_v0 = $temp$_v0;
					continue chompOneOf;
				default:
					var error = _v2.a;
					return $author$project$Step$Decode$Failed(error);
			}
		} else {
			return $author$project$Step$Decode$UnexpectedType;
		}
	}
};
var $author$project$Step$Decode$chompOneOf = F3($author$project$Step$Decode$chompOneOf$);
var $author$project$Step$Decode$oneOf = function (entityDecoders) {
	return $author$project$Step$Decode$makeEntityDecoder(
		$author$project$Step$Decode$chompOneOf(entityDecoders));
};
var $author$project$StepImport$Placement$ = function (origin, axis, ref) {
	return {w: axis, z: origin, cB: ref};
};
var $author$project$StepImport$Placement = F3($author$project$StepImport$Placement$);
var $author$project$Step$Pattern$Maybe = function (a) {
	return {$: 1, a: a};
};
var $author$project$Step$Pattern$maybe = $author$project$Step$Pattern$Maybe;
var $author$project$Step$Pattern$anyCharacter = $author$project$Step$Pattern$Pattern('.');
var $author$project$Step$Pattern$railwayToken = function (pattern) {
	return $author$project$Step$Pattern$oneOf(
		_List_fromArray(
			[
				pattern,
				$author$project$Step$Pattern$zeroOrMore($author$project$Step$Pattern$anyCharacter)
			]));
};
var $author$project$Step$Pattern$railway$ = function (separator, patterns) {
	return $author$project$Step$Pattern$maybe(
		$author$project$Step$Pattern$sequence(
			$elm$core$List$intersperse$(
				separator,
				$elm$core$List$map$($author$project$Step$Pattern$railwayToken, patterns))));
};
var $author$project$Step$Pattern$railway = F2($author$project$Step$Pattern$railway$);
var $author$project$Step$Decode$simpleEntityPattern$ = function (typeName, attributePatterns) {
	var attributeSeparatorPattern = $author$project$Step$Pattern$sequence(
		_List_fromArray(
			[
				$author$project$Step$Pattern$whitespace,
				$author$project$Step$Pattern$token(','),
				$author$project$Step$Pattern$whitespace
			]));
	var attributesPattern = $author$project$Step$Pattern$railway$(attributeSeparatorPattern, attributePatterns);
	return $author$project$Step$Pattern$sequence(
		_List_fromArray(
			[
				$author$project$Step$Pattern$startOfInput,
				$author$project$Step$Pattern$token(typeName),
				$author$project$Step$Pattern$whitespace,
				$author$project$Step$Pattern$token('('),
				$author$project$Step$Pattern$whitespace,
				attributesPattern,
				$author$project$Step$Pattern$whitespace,
				$author$project$Step$Pattern$token(')'),
				$author$project$Step$Pattern$endOfInput
			]));
};
var $author$project$Step$Decode$simpleEntityPattern = F2($author$project$Step$Decode$simpleEntityPattern$);
var $author$project$Step$Decode$simpleEntityRegex$ = function (typeName, attributePatterns) {
	return $author$project$Step$Pattern$compile(
		$author$project$Step$Decode$simpleEntityPattern$(typeName, attributePatterns));
};
var $author$project$Step$Decode$simpleEntityRegex = F2($author$project$Step$Decode$simpleEntityRegex$);
var $author$project$Step$Decode$simpleEntityDecoder$ = function (callback, typeName, attributePatterns, chompAttributes) {
	var regex = $author$project$Step$Decode$simpleEntityRegex$(typeName, attributePatterns);
	return $author$project$Step$Decode$makeEntityDecoder(
		F2(
			function (entityLine, _v0) {
				var _v1 = A2($elm$regex$Regex$find, regex, entityLine.am);
				if (!_v1.b) {
					return $author$project$Step$Decode$UnexpectedType;
				} else {
					if (!_v1.b.b) {
						var submatches = _v1.a.fB;
						var _v2 = A2(chompAttributes, entityLine, submatches);
						switch (_v2.$) {
							case 0:
								var handler = _v2.a;
								var remaining = _v2.b;
								return $author$project$Step$Decode$Succeeded$(
									handler(callback),
									remaining);
							case 1:
								var error = _v2.a;
								return $author$project$Step$Decode$Failed(error);
							default:
								return $author$project$Step$Decode$unexpectedTypeFromAttribute;
						}
					} else {
						var _v3 = _v1.b;
						return $author$project$Step$Decode$internalError('more than one regex match for a single entity');
					}
				}
			}));
};
var $author$project$Step$Decode$simpleEntityDecoder = F4($author$project$Step$Decode$simpleEntityDecoder$);
var $author$project$Step$Decode$thenChomp$ = function (chomp2, chomp1) {
	return F2(
		function (entityLine, submatches) {
			var _v0 = A2(chomp1, entityLine, submatches);
			switch (_v0.$) {
				case 0:
					var result1 = _v0.a;
					var after1 = _v0.b;
					var _v1 = A2(chomp2, entityLine, after1);
					switch (_v1.$) {
						case 0:
							var result2 = _v1.a;
							var after2 = _v1.b;
							return $author$project$Step$Decode$Succeeded$(
								A2($elm$core$Basics$composeR, result1, result2),
								after2);
						case 1:
							var error = _v1.a;
							return $author$project$Step$Decode$Failed(error);
						default:
							return $author$project$Step$Decode$UnexpectedType;
					}
				case 1:
					var error = _v0.a;
					return $author$project$Step$Decode$Failed(error);
				default:
					return $author$project$Step$Decode$UnexpectedType;
			}
		});
};
var $author$project$Step$Decode$thenChomp = F2($author$project$Step$Decode$thenChomp$);
var $author$project$Step$Decode$simpleEntity2$ = function (callback, contextDecoder, idDecoder, typeName, firstAttributeDecoder, secondAttributeDecoder) {
	var _v0 = idDecoder;
	var chompId = _v0.b;
	var _v1 = contextDecoder;
	var chompContext = _v1.b;
	var _v2 = secondAttributeDecoder;
	var pattern2 = _v2.a;
	var chomp2 = _v2.b;
	var _v3 = firstAttributeDecoder;
	var pattern1 = _v3.a;
	var chomp1 = _v3.b;
	var chomp = $author$project$Step$Decode$thenChomp$(
		chomp2,
		$author$project$Step$Decode$thenChomp$(
			chomp1,
			$author$project$Step$Decode$thenChomp$(chompId, chompContext)));
	var attributePatterns = _List_fromArray(
		[pattern1, pattern2]);
	return $author$project$Step$Decode$simpleEntityDecoder$(callback, typeName, attributePatterns, chomp);
};
var $author$project$Step$Decode$simpleEntity2 = F6($author$project$Step$Decode$simpleEntity2$);
var $author$project$Step$Decode$string = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$string,
	F2(
		function (_v0, submatches) {
			if (submatches.b) {
				if (!submatches.a.$) {
					var submatch = submatches.a.a;
					var rest = submatches.b;
					return $author$project$Step$Decode$Succeeded$(
						$author$project$Step$String$decode(
							A3($elm$core$String$slice, 1, -1, submatch)),
						rest);
				} else {
					var _v2 = submatches.a;
					return $author$project$Step$Decode$couldNotParseAttributeAs('string');
				}
			} else {
				return $author$project$Step$Decode$wrongNumberOfSubmatches;
			}
		}));
var $author$project$Step$Decode$validate$ = function (_function, decoder) {
	var _v0 = decoder;
	var pattern = _v0.a;
	var chomp = _v0.b;
	return $author$project$Step$Decode$Decoder$(
		pattern,
		F2(
			function (entityLine, submatches) {
				var _v1 = A2(chomp, entityLine, submatches);
				switch (_v1.$) {
					case 0:
						var value = _v1.a;
						var remaining = _v1.b;
						var _v2 = _function(value);
						if (!_v2.$) {
							var result = _v2.a;
							return $author$project$Step$Decode$Succeeded$(result, remaining);
						} else {
							var message = _v2.a;
							return $author$project$Step$Decode$errorMessage(message);
						}
					case 1:
						var error = _v1.a;
						return $author$project$Step$Decode$Failed(error);
					default:
						return $author$project$Step$Decode$UnexpectedType;
				}
			}));
};
var $author$project$Step$Decode$validate = F2($author$project$Step$Decode$validate$);
var $author$project$Step$Decode$tuple3 = function (itemDecoder) {
	return $author$project$Step$Decode$validate$(
		function (items) {
			if (((items.b && items.b.b) && items.b.b.b) && (!items.b.b.b.b)) {
				var first = items.a;
				var _v1 = items.b;
				var second = _v1.a;
				var _v2 = _v1.b;
				var third = _v2.a;
				return $elm$core$Result$Ok(
					_Utils_Tuple3(first, second, third));
			} else {
				return $elm$core$Result$Err(
					'Expected 3 items in list, found ' + $elm$core$String$fromInt(
						$elm$core$List$length(items)));
			}
		},
		$author$project$Step$Decode$list(itemDecoder));
};
var $author$project$StepImport$direction = $author$project$Step$Decode$simpleEntity2$(
	function (_v0) {
		var x = _v0.a;
		var y = _v0.b;
		var z = _v0.c;
		return {m: x, n: y, o: z};
	},
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'DIRECTION',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$tuple3($author$project$Step$Decode$float)));
var $author$project$Step$Pattern$null = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$token('$'));
var $author$project$Step$Pattern$optional = function (pattern) {
	return $author$project$Step$Pattern$oneOf(
		_List_fromArray(
			[$author$project$Step$Pattern$null, pattern]));
};
var $author$project$Step$Decode$optional = function (decoder) {
	var _v0 = decoder;
	var attributePattern = _v0.a;
	var chompItem = _v0.b;
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$optional(attributePattern),
		F2(
			function (entityLine, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						if (submatches.b.b) {
							var _v2 = submatches.b;
							var rest = _v2.b;
							return $author$project$Step$Decode$Succeeded$($elm$core$Maybe$Nothing, rest);
						} else {
							return $author$project$Step$Decode$wrongNumberOfSubmatches;
						}
					} else {
						var _v3 = submatches.a;
						var rest = submatches.b;
						var _v4 = A2(chompItem, entityLine, rest);
						switch (_v4.$) {
							case 0:
								var value = _v4.a;
								var remaining = _v4.b;
								return $author$project$Step$Decode$Succeeded$(
									$elm$core$Maybe$Just(value),
									remaining);
							case 1:
								var error = _v4.a;
								return $author$project$Step$Decode$Failed(error);
							default:
								return $author$project$Step$Decode$unexpectedTypeFromAttribute;
						}
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$StepImport$point = $author$project$Step$Decode$simpleEntity2$(
	function (_v0) {
		var x = _v0.a;
		var y = _v0.b;
		var z = _v0.c;
		return {m: x, n: y, o: z};
	},
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'CARTESIAN_POINT',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$tuple3($author$project$Step$Decode$float)));
var $author$project$Step$Decode$dropId$ = function (_v0, value) {
	return value;
};
var $author$project$Step$Decode$dropId = F2($author$project$Step$Decode$dropId$);
var $author$project$Step$Decode$entityHasUnexpectedType = function (id) {
	return {
		by: _List_fromArray(
			[id]),
		bB: 'Entity has unexpected type'
	};
};
var $author$project$Step$Decode$noEntityWithId = function (id) {
	return 'No entity with ID ' + $author$project$Step$Decode$idString(id);
};
var $author$project$Step$Pattern$referencedId = $author$project$Step$Pattern$capture(
	$author$project$Step$Pattern$Pattern('#\\d+'));
var $author$project$Step$Decode$referenceWithId$ = function (combine, entityDecoder) {
	return $author$project$Step$Decode$Decoder$(
		$author$project$Step$Pattern$referencedId,
		F2(
			function (entityLine, submatches) {
				if (submatches.b) {
					if (!submatches.a.$) {
						var submatch = submatches.a.a;
						var rest = submatches.b;
						var _v1 = $elm$core$String$toInt(
							$elm$core$String$dropLeft$(1, submatch));
						if (!_v1.$) {
							var childId = _v1.a;
							var _v2 = entityLine.ac;
							var entities = _v2.b;
							var _v3 = $elm$core$Array$get$(childId, entities);
							if (!_v3.$) {
								var childEntityString = _v3.a;
								var childEntityLine = {W: entityLine.W, ac: entityLine.ac, bX: childId, am: childEntityString};
								var _v4 = $author$project$Step$Decode$decodeEntity$(entityDecoder, childEntityLine);
								switch (_v4.$) {
									case 0:
										var value = _v4.a;
										return $author$project$Step$Decode$Succeeded$(
											A2(combine, childId, value),
											rest);
									case 2:
										return $author$project$Step$Decode$Failed(
											$author$project$Step$Decode$entityHasUnexpectedType(childId));
									default:
										var error = _v4.a;
										return $author$project$Step$Decode$Failed(error);
								}
							} else {
								return $author$project$Step$Decode$errorMessage(
									$author$project$Step$Decode$noEntityWithId(childId));
							}
						} else {
							return $author$project$Step$Decode$internalError('failed to parse referenced ID \'' + (submatch + '\''));
						}
					} else {
						var _v5 = submatches.a;
						return $author$project$Step$Decode$couldNotParseAttributeAs('entity reference');
					}
				} else {
					return $author$project$Step$Decode$wrongNumberOfSubmatches;
				}
			}));
};
var $author$project$Step$Decode$referenceWithId = F2($author$project$Step$Decode$referenceWithId$);
var $author$project$Step$Decode$referenceTo = function (entityDecoder) {
	return $author$project$Step$Decode$referenceWithId$($author$project$Step$Decode$dropId, entityDecoder);
};
var $author$project$Step$Decode$simpleEntity4$ = function (callback, contextDecoder, idDecoder, typeName, firstAttributeDecoder, secondAttributeDecoder, thirdAttributeDecoder, fourthAttributeDecoder) {
	var _v0 = idDecoder;
	var chompId = _v0.b;
	var _v1 = contextDecoder;
	var chompContext = _v1.b;
	var _v2 = fourthAttributeDecoder;
	var pattern4 = _v2.a;
	var chomp4 = _v2.b;
	var _v3 = thirdAttributeDecoder;
	var pattern3 = _v3.a;
	var chomp3 = _v3.b;
	var _v4 = secondAttributeDecoder;
	var pattern2 = _v4.a;
	var chomp2 = _v4.b;
	var _v5 = firstAttributeDecoder;
	var pattern1 = _v5.a;
	var chomp1 = _v5.b;
	var chomp = $author$project$Step$Decode$thenChomp$(
		chomp4,
		$author$project$Step$Decode$thenChomp$(
			chomp3,
			$author$project$Step$Decode$thenChomp$(
				chomp2,
				$author$project$Step$Decode$thenChomp$(
					chomp1,
					$author$project$Step$Decode$thenChomp$(chompId, chompContext)))));
	var attributePatterns = _List_fromArray(
		[pattern1, pattern2, pattern3, pattern4]);
	return $author$project$Step$Decode$simpleEntityDecoder$(callback, typeName, attributePatterns, chomp);
};
var $author$project$Step$Decode$simpleEntity4 = F8($author$project$Step$Decode$simpleEntity4$);
var $author$project$StepImport$placement = $author$project$Step$Decode$simpleEntity4$(
	$author$project$StepImport$Placement,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'AXIS2_PLACEMENT_3D',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$point)),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$optional(
			$author$project$Step$Decode$referenceTo($author$project$StepImport$direction))),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$optional(
			$author$project$Step$Decode$referenceTo($author$project$StepImport$direction))));
var $author$project$Step$Decode$referencedId = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$referencedId,
	F2(
		function (_v0, submatches) {
			if (submatches.b) {
				if (!submatches.a.$) {
					var submatch = submatches.a.a;
					var rest = submatches.b;
					var _v2 = $elm$core$String$toInt(
						$elm$core$String$dropLeft$(1, submatch));
					if (!_v2.$) {
						var id = _v2.a;
						return $author$project$Step$Decode$Succeeded$(id, rest);
					} else {
						return $author$project$Step$Decode$internalError('failed to parse referenced ID \'' + (submatch + '\''));
					}
				} else {
					var _v3 = submatches.a;
					return $author$project$Step$Decode$couldNotParseAttributeAs('entity reference');
				}
			} else {
				return $author$project$Step$Decode$wrongNumberOfSubmatches;
			}
		}));
var $author$project$Step$Decode$simpleEntity3$ = function (callback, contextDecoder, idDecoder, typeName, firstAttributeDecoder, secondAttributeDecoder, thirdAttributeDecoder) {
	var _v0 = idDecoder;
	var chompId = _v0.b;
	var _v1 = contextDecoder;
	var chompContext = _v1.b;
	var _v2 = thirdAttributeDecoder;
	var pattern3 = _v2.a;
	var chomp3 = _v2.b;
	var _v3 = secondAttributeDecoder;
	var pattern2 = _v3.a;
	var chomp2 = _v3.b;
	var _v4 = firstAttributeDecoder;
	var pattern1 = _v4.a;
	var chomp1 = _v4.b;
	var chomp = $author$project$Step$Decode$thenChomp$(
		chomp3,
		$author$project$Step$Decode$thenChomp$(
			chomp2,
			$author$project$Step$Decode$thenChomp$(
				chomp1,
				$author$project$Step$Decode$thenChomp$(chompId, chompContext))));
	var attributePatterns = _List_fromArray(
		[pattern1, pattern2, pattern3]);
	return $author$project$Step$Decode$simpleEntityDecoder$(callback, typeName, attributePatterns, chomp);
};
var $author$project$Step$Decode$simpleEntity3 = F7($author$project$Step$Decode$simpleEntity3$);
var $author$project$StepImport$surfaceCurve = function (typeName) {
	return $author$project$Step$Decode$simpleEntity4$(
		$elm$core$Basics$identity,
		$author$project$Step$Decode$ignoreContext,
		$author$project$Step$Decode$ignoreId,
		typeName,
		$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
		$author$project$Step$Decode$keep(
			$author$project$Step$Decode$referenceTo(
				$author$project$Step$Decode$lazy(
					function (_v0) {
						return $author$project$StepImport$cyclic$curve();
					}))),
		$author$project$Step$Decode$ignore(
			$author$project$Step$Decode$list($author$project$Step$Decode$referencedId)),
		$author$project$Step$Decode$ignore(
			$author$project$Step$Decode$enum(
				_List_fromArray(
					[
						_Utils_Tuple2('CURVE_3D', 0),
						_Utils_Tuple2('PCURVE_S1', 0),
						_Utils_Tuple2('PCURVE_S2', 0)
					]))));
};
function $author$project$StepImport$cyclic$curve() {
	return $author$project$Step$Decode$oneOf(
		_List_fromArray(
			[
				$author$project$Step$Decode$simpleEntity3$(
				$author$project$StepImport$LineCurve,
				$author$project$Step$Decode$ignoreContext,
				$author$project$Step$Decode$ignoreId,
				'LINE',
				$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
				$author$project$Step$Decode$ignore($author$project$Step$Decode$referencedId),
				$author$project$Step$Decode$ignore($author$project$Step$Decode$referencedId)),
				$author$project$Step$Decode$simpleEntity3$(
				F2(
					function (placement_, radius) {
						return $author$project$StepImport$CircleCurve(
							{H: placement_, p: radius});
					}),
				$author$project$Step$Decode$ignoreContext,
				$author$project$Step$Decode$ignoreId,
				'CIRCLE',
				$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
				$author$project$Step$Decode$keep(
					$author$project$Step$Decode$referenceTo($author$project$StepImport$placement)),
				$author$project$Step$Decode$keep($author$project$Step$Decode$float)),
				$author$project$StepImport$surfaceCurve('SURFACE_CURVE'),
				$author$project$StepImport$surfaceCurve('SEAM_CURVE')
			]));
}
var $author$project$StepImport$curve = $author$project$StepImport$cyclic$curve();
$author$project$StepImport$cyclic$curve = function () {
	return $author$project$StepImport$curve;
};
var $author$project$Step$Decode$keepId = $author$project$Step$Decode$Decoder$(
	$author$project$Step$Pattern$startOfInput,
	F2(
		function (entityLine, submatches) {
			return $author$project$Step$Decode$Succeeded$(
				$elm$core$Basics$apR(entityLine.bX),
				submatches);
		}));
var $author$project$Step$Decode$simpleEntity5$ = function (callback, contextDecoder, idDecoder, typeName, firstAttributeDecoder, secondAttributeDecoder, thirdAttributeDecoder, fourthAttributeDecoder, fifthAttributeDecoder) {
	var _v0 = idDecoder;
	var chompId = _v0.b;
	var _v1 = contextDecoder;
	var chompContext = _v1.b;
	var _v2 = fifthAttributeDecoder;
	var pattern5 = _v2.a;
	var chomp5 = _v2.b;
	var _v3 = fourthAttributeDecoder;
	var pattern4 = _v3.a;
	var chomp4 = _v3.b;
	var _v4 = thirdAttributeDecoder;
	var pattern3 = _v4.a;
	var chomp3 = _v4.b;
	var _v5 = secondAttributeDecoder;
	var pattern2 = _v5.a;
	var chomp2 = _v5.b;
	var _v6 = firstAttributeDecoder;
	var pattern1 = _v6.a;
	var chomp1 = _v6.b;
	var chomp = $author$project$Step$Decode$thenChomp$(
		chomp5,
		$author$project$Step$Decode$thenChomp$(
			chomp4,
			$author$project$Step$Decode$thenChomp$(
				chomp3,
				$author$project$Step$Decode$thenChomp$(
					chomp2,
					$author$project$Step$Decode$thenChomp$(
						chomp1,
						$author$project$Step$Decode$thenChomp$(chompId, chompContext))))));
	var attributePatterns = _List_fromArray(
		[pattern1, pattern2, pattern3, pattern4, pattern5]);
	return $author$project$Step$Decode$simpleEntityDecoder$(callback, typeName, attributePatterns, chomp);
};
var $author$project$Step$Decode$simpleEntity5 = F9($author$project$Step$Decode$simpleEntity5$);
var $author$project$StepImport$vertex = $author$project$Step$Decode$simpleEntity2$(
	$elm$core$Basics$identity,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'VERTEX_POINT',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$point)));
var $author$project$StepImport$edgeCurve = $author$project$Step$Decode$simpleEntity5$(
	$author$project$StepImport$Edge,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$keepId,
	'EDGE_CURVE',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$vertex)),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$vertex)),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$curve)),
	$author$project$Step$Decode$keep($author$project$Step$Decode$bool));
var $author$project$StepImport$orientedEdge = $author$project$Step$Decode$simpleEntity5$(
	$elm$core$Tuple$pair,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'ORIENTED_EDGE',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$ignore(
		$author$project$Step$Decode$derivedValue(0)),
	$author$project$Step$Decode$ignore(
		$author$project$Step$Decode$derivedValue(0)),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$edgeCurve)),
	$author$project$Step$Decode$keep($author$project$Step$Decode$bool));
var $author$project$StepImport$edgeLoop = $author$project$Step$Decode$simpleEntity2$(
	$elm$core$Basics$identity,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'EDGE_LOOP',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$list(
			$author$project$Step$Decode$referenceTo($author$project$StepImport$orientedEdge))));
var $author$project$StepImport$bound = function () {
	var ofType = F2(
		function (outer, typeName) {
			return $author$project$Step$Decode$simpleEntity3$(
				F2(
					function (edges, sameSense) {
						return {bS: edges, b0: outer, Y: sameSense};
					}),
				$author$project$Step$Decode$ignoreContext,
				$author$project$Step$Decode$ignoreId,
				typeName,
				$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
				$author$project$Step$Decode$keep(
					$author$project$Step$Decode$referenceTo($author$project$StepImport$edgeLoop)),
				$author$project$Step$Decode$keep($author$project$Step$Decode$bool));
		});
	return $author$project$Step$Decode$oneOf(
		_List_fromArray(
			[
				A2(ofType, true, 'FACE_OUTER_BOUND'),
				A2(ofType, false, 'FACE_BOUND')
			]));
}();
var $author$project$StepImport$geometry = $author$project$Step$Decode$oneOf(
	_List_fromArray(
		[
			$author$project$Step$Decode$simpleEntity2$(
			$author$project$StepImport$Plane,
			$author$project$Step$Decode$ignoreContext,
			$author$project$Step$Decode$ignoreId,
			'PLANE',
			$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
			$author$project$Step$Decode$keep(
				$author$project$Step$Decode$referenceTo($author$project$StepImport$placement))),
			$author$project$Step$Decode$simpleEntity3$(
			$author$project$StepImport$Cylinder,
			$author$project$Step$Decode$ignoreContext,
			$author$project$Step$Decode$ignoreId,
			'CYLINDRICAL_SURFACE',
			$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
			$author$project$Step$Decode$keep(
				$author$project$Step$Decode$referenceTo($author$project$StepImport$placement)),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float)),
			$author$project$Step$Decode$simpleEntity4$(
			$author$project$StepImport$Cone,
			$author$project$Step$Decode$ignoreContext,
			$author$project$Step$Decode$ignoreId,
			'CONICAL_SURFACE',
			$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
			$author$project$Step$Decode$keep(
				$author$project$Step$Decode$referenceTo($author$project$StepImport$placement)),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float)),
			$author$project$Step$Decode$simpleEntity3$(
			$author$project$StepImport$Sphere,
			$author$project$Step$Decode$ignoreContext,
			$author$project$Step$Decode$ignoreId,
			'SPHERICAL_SURFACE',
			$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
			$author$project$Step$Decode$keep(
				$author$project$Step$Decode$referenceTo($author$project$StepImport$placement)),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float)),
			$author$project$Step$Decode$simpleEntity4$(
			$author$project$StepImport$Torus,
			$author$project$Step$Decode$ignoreContext,
			$author$project$Step$Decode$ignoreId,
			'TOROIDAL_SURFACE',
			$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
			$author$project$Step$Decode$keep(
				$author$project$Step$Decode$referenceTo($author$project$StepImport$placement)),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float),
			$author$project$Step$Decode$keep($author$project$Step$Decode$float))
		]));
var $author$project$StepImport$face = $author$project$Step$Decode$simpleEntity4$(
	F4(
		function (id, bounds, geometry_, sameSense) {
			return {at: bounds, bT: geometry_, bX: id, Y: sameSense};
		}),
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$keepId,
	'ADVANCED_FACE',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$list(
			$author$project$Step$Decode$referenceTo($author$project$StepImport$bound))),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$referenceTo($author$project$StepImport$geometry)),
	$author$project$Step$Decode$keep($author$project$Step$Decode$bool));
var $author$project$StepImport$shell = $author$project$Step$Decode$simpleEntity2$(
	$elm$core$Basics$identity,
	$author$project$Step$Decode$ignoreContext,
	$author$project$Step$Decode$ignoreId,
	'CLOSED_SHELL',
	$author$project$Step$Decode$ignore($author$project$Step$Decode$string),
	$author$project$Step$Decode$keep(
		$author$project$Step$Decode$list(
			$author$project$Step$Decode$referenceTo($author$project$StepImport$face))));
var $elm$core$String$filter = _String_filter;
var $author$project$StepImport$unitsOf = function (text) {
	var siPrefix = function (entity) {
		var _v2 = $elm$core$Maybe$andThen$(
			A2(
				$elm$core$Basics$composeR,
				function ($) {
					return $.fB;
				},
				A2(
					$elm$core$Basics$composeR,
					$elm$core$List$head,
					$elm$core$Maybe$andThen($elm$core$Basics$identity))),
			$elm$core$List$head(
				A2(
					$elm$regex$Regex$find,
					$author$project$StepImport$regex('SI_UNIT\\(\\.(\\w+)\\.,'),
					entity)));
		_v2$5:
		while (true) {
			if (!_v2.$) {
				switch (_v2.a) {
					case 'MILLI':
						return 0.001;
					case 'CENTI':
						return 0.01;
					case 'DECI':
						return 0.1;
					case 'KILO':
						return 1000;
					case 'MICRO':
						return 1.0e-6;
					default:
						break _v2$5;
				}
			} else {
				break _v2$5;
			}
		}
		return 1;
	};
	var conversion = function (entity) {
		return $elm$core$Maybe$map$(
			$elm$core$String$toUpper,
			$elm$core$Maybe$andThen$(
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.fB;
					},
					A2(
						$elm$core$Basics$composeR,
						$elm$core$List$head,
						$elm$core$Maybe$andThen($elm$core$Basics$identity))),
				$elm$core$List$head(
					A2(
						$elm$regex$Regex$find,
						$author$project$StepImport$regex('CONVERSION_BASED_UNIT\\(\'([^\']*)\''),
						entity))));
	};
	var compact = A2(
		$elm$core$String$filter,
		function (c) {
			return (c !== ' ') && ((c !== '\n') && ((c !== '\u000D') && (c !== '\t')));
		},
		text);
	var unitEntity = function (kind) {
		return $elm$core$Maybe$withDefault$(
			'',
			$elm$core$Maybe$andThen$(
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.fB;
					},
					A2(
						$elm$core$Basics$composeR,
						$elm$core$List$head,
						$elm$core$Maybe$andThen($elm$core$Basics$identity))),
				$elm$core$List$head(
					A2(
						$elm$regex$Regex$find,
						$author$project$StepImport$regex('\\(([^;]*' + (kind + '\\(\\)[^;]*)\\);')),
						compact))));
	};
	var length = function () {
		var entity = unitEntity('LENGTH_UNIT');
		var _v1 = conversion(entity);
		_v1$4:
		while (true) {
			if (!_v1.$) {
				switch (_v1.a) {
					case 'INCH':
						return 0.0254;
					case 'FOOT':
						return 0.3048;
					case 'MILLIMETRE':
						return 0.001;
					case 'MILLIMETER':
						return 0.001;
					default:
						break _v1$4;
				}
			} else {
				break _v1$4;
			}
		}
		return siPrefix(entity);
	}();
	var angle = function () {
		var _v0 = conversion(
			unitEntity('PLANE_ANGLE_UNIT'));
		_v0$2:
		while (true) {
			if (!_v0.$) {
				switch (_v0.a) {
					case 'DEGREE':
						return $elm$core$Basics$pi / 180;
					case 'DEGREES':
						return $elm$core$Basics$pi / 180;
					default:
						break _v0$2;
				}
			} else {
				break _v0$2;
			}
		}
		return 1;
	}();
	return {fS: angle, aR: length};
};
var $author$project$StepImport$surface$ = function (userScale, text) {
	var _v0 = $author$project$Step$Decode$parse(text);
	if (!_v0.$) {
		var file = _v0.a;
		var _v1 = $author$project$Step$Decode$all$($author$project$StepImport$shell, file, 0);
		if (!_v1.$) {
			if (_v1.a.b) {
				if (!_v1.a.b.b) {
					var _v2 = _v1.a;
					var faces = _v2.a;
					var units = $author$project$StepImport$unitsOf(text);
					var convert = {
						fS: function (a) {
							return a * units.fS;
						},
						dU: function (d) {
							return {m: d.m, n: d.o, o: -d.n};
						},
						aR: function (l) {
							return (l * units.aR) * userScale;
						},
						dk: function (p) {
							return $author$project$StepImport$scale$(
								units.aR * userScale,
								{m: p.m, n: p.o, o: -p.n});
						}
					};
					return $elm$core$Result$andThen$(
						function (pieces) {
							return $elm$core$Result$mapError$(
								function (error) {
									return 'The faces don\'t fit together: ' + $author$project$Surface$errorToString(error);
								},
								A2(
									$author$project$Surface$build,
									$elm$core$List$filterMap$(
										function (piece) {
											if (!piece.$) {
												var flat = piece.a;
												return $elm$core$Maybe$Just(flat);
											} else {
												return $elm$core$Maybe$Nothing;
											}
										},
										pieces),
									$elm$core$List$filterMap$(
										function (piece) {
											if (!piece.$) {
												return $elm$core$Maybe$Nothing;
											} else {
												var feature = piece.a;
												return $elm$core$Maybe$Just(feature);
											}
										},
										pieces)));
						},
						$author$project$StepImport$combine(
							$elm$core$List$map$(
								function (face_) {
									return $elm$core$Result$mapError$(
										function (message) {
											return 'Face #' + ($elm$core$String$fromInt(face_.bX) + (': ' + message));
										},
										$author$project$StepImport$pieceOf(face_));
								},
								$elm$core$List$map$(
									$author$project$StepImport$convertFace(convert),
									faces))));
				} else {
					var shells = _v1.a;
					return $elm$core$Result$Err(
						'The file has ' + ($elm$core$String$fromInt(
							$elm$core$List$length(shells)) + ' solids in it; export just one'));
				}
			} else {
				return $elm$core$Result$Err('The file has no solid in it (a closed shell)');
			}
		} else {
			var message = _v1.a;
			return $elm$core$Result$Err(
				$author$project$StepImport$explain$(text, message));
		}
	} else {
		var message = _v0.a;
		return $elm$core$Result$Err(message);
	}
};
var $author$project$StepImport$surface = F2($author$project$StepImport$surface$);
var $author$project$Surface$SurfacePoint = $elm$core$Basics$identity;
var $author$project$Surface$surfacePointDecoder = A5(
	$elm$json$Json$Decode$map4,
	F4(
		function (piece, a, b, heading) {
			return {cK: a, cM: b, i: heading, aq: piece};
		}),
	A2($elm$json$Json$Decode$field, 'piece', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'a', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'b', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'heading', $elm$json$Json$Decode$float));
var $author$project$MinimapWorker$update$ = function (_v0, model_) {
	var value = _v0;
	var _v1 = A2($elm$json$Json$Decode$decodeValue, $author$project$MinimapWorker$importDecoder, value);
	if (!_v1.$) {
		var _v2 = _v1.a;
		var text = _v2.a;
		var scale = _v2.b;
		return _Utils_Tuple2(
			{
				bF: {cz: _List_Nil, jE: _List_Nil},
				bG: $author$project$Shapes$empty,
				b4: $elm$core$Result$toMaybe(
					$author$project$StepImport$surface$(scale, text))
			},
			$elm$core$Platform$Cmd$none);
	} else {
		var model = function () {
			var _v6 = A2(
				$elm$json$Json$Decode$decodeValue,
				A2(
					$elm$json$Json$Decode$field,
					'ground',
					$elm$json$Json$Decode$nullable($author$project$GridLevel$decoder)),
				value);
			if (!_v6.$) {
				if (!_v6.a.$) {
					var ground = _v6.a.a;
					var surface = $elm$core$Result$toMaybe(
						$author$project$GridLevel$surface(ground));
					var edges = $elm$core$List$map$(
						A2(
							$elm$core$Basics$composeR,
							$author$project$GridLevel$edgeSamples,
							$elm$core$List$map(
								function (_v7) {
									var position = _v7.gQ;
									return _Utils_Tuple3(position.m, position.n, position.o);
								})),
						$author$project$GridLevel$openEdges(ground));
					return {
						bF: {cz: _List_Nil, jE: edges},
						bG: $elm$core$Maybe$withDefault$(
							$author$project$Shapes$empty,
							$elm$core$Maybe$map$(
								function (surface_) {
									return $author$project$Shapes$prepare$(surface_, edges, _List_Nil);
								},
								surface)),
						b4: surface
					};
				} else {
					var _v8 = _v6.a;
					return $author$project$MinimapWorker$init;
				}
			} else {
				return model_;
			}
		}();
		var _v3 = _Utils_Tuple2(
			A2(
				$elm$json$Json$Decode$decodeValue,
				A3(
					$elm$json$Json$Decode$map2,
					$elm$core$Tuple$pair,
					A2($elm$json$Json$Decode$field, 'point', $author$project$Surface$surfacePointDecoder),
					$elm$json$Json$Decode$maybe(
						A2($elm$json$Json$Decode$field, 'placed', $author$project$MinimapWorker$placedDecoder))),
				value),
			model.b4);
		if ((!_v3.a.$) && (!_v3.b.$)) {
			var _v4 = _v3.a.a;
			var point = _v4.a;
			var placed = _v4.b;
			var surface = _v3.b.a;
			var withPlaced = function () {
				if (!placed.$) {
					var paths = placed.a.gO;
					var walls = placed.a.jE;
					return $author$project$Shapes$prepare$(
						surface,
						_Utils_ap(model.bF.jE, walls),
						_Utils_ap(
							model.bF.cz,
							$elm$core$List$map$(
								A2($author$project$Shapes$pathPaving, surface, $author$project$Shapes$pathWidth),
								paths)));
				} else {
					return model.bG;
				}
			}();
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{bG: withPlaced}),
				$author$project$MinimapWorker$minimapDrawn(
					$elm$json$Json$Encode$object(
						_List_fromArray(
							[
								_Utils_Tuple2(
								'point',
								$author$project$Surface$encodeSurfacePoint(point)),
								_Utils_Tuple2(
								'drawing',
								$author$project$Minimap$encodeDrawing(
									$author$project$Minimap$drawingAround$(surface, withPlaced, point)))
							]))));
		} else {
			return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	}
};
var $author$project$MinimapWorker$update = F2($author$project$MinimapWorker$update$);
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$MinimapWorker$main = $elm$core$Platform$worker(
	{
		ia: function (_v0) {
			return _Utils_Tuple2($author$project$MinimapWorker$init, $elm$core$Platform$Cmd$none);
		},
		jf: function (_v1) {
			return $author$project$MinimapWorker$drawMinimap($elm$core$Basics$identity);
		},
		jB: $author$project$MinimapWorker$update
	});
_Platform_export({'MinimapWorker':{'init':$author$project$MinimapWorker$main(
	$elm$json$Json$Decode$succeed(0))(0)}});function _Debug_toAnsiString(ansi, value)
{
  if (typeof value === 'function')
  {
    return _Debug_internalColor(ansi, '<function>');
  }

  if (typeof value === 'boolean')
  {
    return _Debug_ctorColor(ansi, value ? 'True' : 'False');
  }

  if (typeof value === 'number')
  {
    return _Debug_numberColor(ansi, value + '');
  }

  if (value instanceof String)
  {
    return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
  }

  if (typeof value === 'string')
  {
    return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
  }

  if (typeof value === 'object' && '$' in value)
  {
    var tag = value.$;

    if (typeof tag === 'number')
    {
      return _Debug_internalColor(ansi, '<internals>');
    }

    if (tag[0] === '#')
    {
      var output = [];
      for (var k in value)
      {
        if (k === '$') continue;
        output.push(_Debug_toAnsiString(ansi, value[k]));
      }
      return '(' + output.join(',') + ')';
    }

    if (tag === 'Set_elm_builtin')
    {
      return _Debug_ctorColor(ansi, 'Set')
        + _Debug_fadeColor(ansi, '.fromList') + ' '
        + _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
    }

    if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
    {
      return _Debug_ctorColor(ansi, 'Dict')
        + _Debug_fadeColor(ansi, '.fromList') + ' '
        + _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
    }

    if (tag === 'SeqSet_elm_builtin')
    {
      return _Debug_ctorColor(ansi, 'SeqSet')
        + _Debug_fadeColor(ansi, '.fromList') + ' '
        + _Debug_toAnsiString(ansi, $lamdera$containers$SeqSet$toList(value));
    }

    if (tag === 'SeqDict_elm_builtin')
    {
      return _Debug_ctorColor(ansi, 'SeqDict')
        + _Debug_fadeColor(ansi, '.fromList') + ' '
        + _Debug_toAnsiString(ansi, $lamdera$containers$SeqDict$toList(value));
    }

    if (tag === 'Array_elm_builtin')
    {
      return _Debug_ctorColor(ansi, 'Array')
        + _Debug_fadeColor(ansi, '.fromList') + ' '
        + _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
    }

    if (tag === '::' || tag === '[]')
    {
      var output = '[';

      value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

      for (; value.b; value = value.b) // WHILE_CONS
      {
        output += ',' + _Debug_toAnsiString(ansi, value.a);
      }
      return output + ']';
    }

    var output = '';
    for (var i in value)
    {
      if (i === '$') continue;
      var str = _Debug_toAnsiString(ansi, value[i]);
      var c0 = str[0];
      var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
      output += ' ' + (parenless ? str : '(' + str + ')');
    }
    return _Debug_ctorColor(ansi, tag) + output;
  }

  if (typeof DataView === 'function' && value instanceof DataView)
  {
    return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
  }

  if (typeof File !== 'undefined' && value instanceof File)
  {
    return _Debug_internalColor(ansi, '<' + value.name + '>');
  }

  if (typeof value === 'object')
  {
    var output = [];
    for (var key in value)
    {
      var field = key[0] === '_' ? key.slice(1) : key;
      output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
    }
    if (output.length === 0)
    {
      return '{}';
    }
    return '{ ' + output.join(', ') + ' }';
  }

  return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
  var s = str
    .replace(/\\/g, '\\\\')
    .replace(/\n/g, '\\n')
    .replace(/\t/g, '\\t')
    .replace(/\r/g, '\\r')
    .replace(/\v/g, '\\v')
    .replace(/\0/g, '\\0');

  if (isChar)
  {
    return s.replace(/\'/g, '\\\'');
  }
  else
  {
    return s.replace(/\"/g, '\\"');
  }
}

function _Utils_eqHelp(x, y, depth, stack)
{
  if (x === y)
  {
    return true;
  }

  if (typeof x !== 'object' || x === null || y === null)
  {
    typeof x === 'function' && $elm$core$Debug$crash(5);
    return false;
  }

  if (depth > 100)
  {
    stack.push(_Utils_Tuple2(x,y));
    return true;
  }

  if (x.$ < 0)
{
  if (x.$ < -10)
  {
    x = $lamdera$containers$SeqDict$toList(x);
    y = $lamdera$containers$SeqDict$toList(y);
  }
  else
  {
    x = $elm$core$Dict$toList(x);
    y = $elm$core$Dict$toList(y);
  }
}

  for (var key in x)
  {
    if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
    {
      return false;
    }
  }
  return true;
}

function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
  {
    var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));

    // @TODO need to figure out how to get this to automatically escape by mode?
    //$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
    $elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);

    var managers = {};
    var initPair = init(result.a);
    var model = (args && args['model']) || initPair.a;

    var stepper = stepperBuilder(sendToApp, model);
    var ports = _Platform_setupEffects(managers, sendToApp);

    var upgradeMode = false;

    var errorHandler = args && args['errorHandler'];

    function sendToApp(msg, viewMetadata)
    {
      if (upgradeMode) {
        // No more messages should run in upgrade mode
        _Platform_enqueueEffects(managers, $elm$core$Platform$Cmd$none, $elm$core$Platform$Sub$none);
        return;
      }

      try {
        var pair = A2(update, msg, model);
        stepper(model = pair.a, viewMetadata);
        _Platform_enqueueEffects(managers, pair.b, subscriptions(model));
      } catch (e) {
        if (errorHandler !== undefined) { errorHandler(e) } else { throw e }
      }
    }

    if ((args && args['model']) === undefined) {
      _Platform_enqueueEffects(managers, initPair.b, subscriptions(model));
    }

    const die = function() {
      // Stop all subscriptions.
      // This must be done before clearing the stuff below.
      _Platform_enqueueEffects(managers, _Platform_batch(_List_Nil), _Platform_batch(_List_Nil));

      managers = null;
      model = null;
      stepper = null;
      ports = null;
      _Platform_effectsQueue = [];
    }

    return ports ? {
      ports: ports,
      gm: function() { return model },
      eum: function() { upgradeMode = true },
      die: die,
      fns: {}
    } : {};
  }}(this));

