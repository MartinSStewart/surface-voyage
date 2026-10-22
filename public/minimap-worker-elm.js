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
	if (region.bQ.fV === region.aH.fV)
	{
		return 'on line ' + region.bQ.fV;
	}
	return 'on lines ' + region.bQ.fV + ' through ' + region.aH.fV;
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
		impl.hJ,
		impl.i2,
		impl.iI,
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
	if (!builder.v) {
		return $elm$core$Array$Array_elm_builtin$(
			$elm$core$Elm$JsArray$length(builder.A),
			$elm$core$Array$shiftStep,
			$elm$core$Elm$JsArray$empty,
			builder.A);
	} else {
		var treeLen = builder.v * $elm$core$Array$branchFactor;
		var depth = $elm$core$Basics$floor(
			$elm$core$Basics$logBase$($elm$core$Array$branchFactor, treeLen - 1));
		var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.E) : builder.E;
		var tree = $elm$core$Array$treeFromBuilder$(correctNodeList, builder.v);
		return $elm$core$Array$Array_elm_builtin$(
			$elm$core$Elm$JsArray$length(builder.A) + treeLen,
			$elm$core$Basics$max$(5, depth * $elm$core$Array$shiftStep),
			tree,
			builder.A);
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
				{E: nodeList, v: (len / $elm$core$Array$branchFactor) | 0, A: tail});
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
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$json$Json$Decode$decodeValue = _Json_run;
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
var $elm$core$List$concatMap$ = function (f, list) {
	return $elm$core$List$concat(
		$elm$core$List$map$(f, list));
};
var $elm$core$List$concatMap = F2($elm$core$List$concatMap$);
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
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
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
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
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
var $elm$core$Basics$pow = _Basics_pow;
var $elm$core$Basics$sqrt = _Basics_sqrt;
var $author$project$Minimap$mapDistance$ = function (a, b) {
	return $elm$core$Basics$sqrt(
		A2($elm$core$Basics$pow, a.i6 - b.i6, 2) + A2($elm$core$Basics$pow, a.ja - b.ja, 2));
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
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $author$project$Minimap$dot$ = function (a, b) {
	return ((a.i6 * b.i6) + (a.ja * b.ja)) + (a.i * b.i);
};
var $author$project$Minimap$dot = F2($author$project$Minimap$dot$);
var $author$project$Minimap$maxOffSurface = 0.05;
var $author$project$Minimap$sub$ = function (a, b) {
	return {i6: a.i6 - b.i6, ja: a.ja - b.ja, i: a.i - b.i};
};
var $author$project$Minimap$sub = F2($author$project$Minimap$sub$);
var $author$project$Minimap$fanImage$ = function (_v0, point) {
	var max = _v0.aM;
	var min = _v0.aN;
	var c = _v0.cu;
	var b = _v0.ct;
	var a = _v0.cr;
	var weights = function (_v3) {
		if (_Utils_eq(a.aa, point.aa) && (_Utils_eq(b.aa, point.aa) && _Utils_eq(c.aa, point.aa))) {
			var e2y = c.z.Q - a.z.Q;
			var e2x = c.z.U - a.z.U;
			var e1y = b.z.Q - a.z.Q;
			var e1x = b.z.U - a.z.U;
			var dy = point.z.Q - a.z.Q;
			var dx = point.z.U - a.z.U;
			var determinant = (e1x * e2y) - (e2x * e1y);
			return ($elm$core$Basics$abs(determinant) < 1.0e-14) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				_Utils_Tuple2(((e2y * dx) - (e2x * dy)) / determinant, ((e1x * dy) - (e1y * dx)) / determinant));
		} else {
			var e2 = $author$project$Minimap$sub$(c.dT, a.dT);
			var g22 = $author$project$Minimap$dot$(e2, e2);
			var e1 = $author$project$Minimap$sub$(b.dT, a.dT);
			var g11 = $author$project$Minimap$dot$(e1, e1);
			var g12 = $author$project$Minimap$dot$(e1, e2);
			var gram = (g11 * g22) - (g12 * g12);
			var d = $author$project$Minimap$sub$(point.dT, a.dT);
			var l1 = ((g22 * $author$project$Minimap$dot$(e1, d)) - (g12 * $author$project$Minimap$dot$(e2, d))) / gram;
			var l2 = ((g11 * $author$project$Minimap$dot$(e2, d)) - (g12 * $author$project$Minimap$dot$(e1, d))) / gram;
			var off = {i6: (d.i6 - (l1 * e1.i6)) - (l2 * e2.i6), ja: (d.ja - (l1 * e1.ja)) - (l2 * e2.ja), i: (d.i - (l1 * e1.i)) - (l2 * e2.i)};
			return ((gram < 1.0e-14) || (($author$project$Minimap$dot$(off, off) - ($author$project$Minimap$maxOffSurface * $author$project$Minimap$maxOffSurface)) > 0)) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				_Utils_Tuple2(l1, l2));
		}
	};
	var p = point.dT;
	var _v1 = (((p.i6 - min.i6) < 0) || (((p.i6 - max.i6) > 0) || (((p.ja - min.ja) < 0) || (((p.ja - max.ja) > 0) || (((p.i - min.i) < 0) || ((p.i - max.i) > 0)))))) ? $elm$core$Maybe$Nothing : weights(0);
	if (!_v1.$) {
		var _v2 = _v1.a;
		var l1 = _v2.a;
		var l2 = _v2.b;
		return (((l1 + 1.0e-3) >= 0) && (((l2 + 1.0e-3) >= 0) && ((l1 + l2) <= 1.001))) ? $elm$core$Maybe$Just(
			{i6: (a.S.i6 + (l1 * (b.S.i6 - a.S.i6))) + (l2 * (c.S.i6 - a.S.i6)), ja: (a.S.ja + (l1 * (b.S.ja - a.S.ja))) + (l2 * (c.S.ja - a.S.ja))}) : $elm$core$Maybe$Nothing;
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Minimap$fanImage = F2($author$project$Minimap$fanImage$);
var $author$project$Shapes$cellSize = 0.2;
var $author$project$Shapes$cellOf = function (coordinate) {
	return $elm$core$Basics$floor(coordinate / $author$project$Shapes$cellSize);
};
var $author$project$Shapes$foldWithin$ = function (box, step, initial, shapes) {
	var grid = shapes.b8;
	var clampCell = F3(
		function (first, count, i) {
			return ((i - first) < 0) ? 0 : ((((i - first) - count) >= 0) ? (count - 1) : (i - first));
		});
	var xTo = A3(
		clampCell,
		grid.bX,
		grid.bK,
		$author$project$Shapes$cellOf(box.aM.i6));
	var _v0 = _Utils_Tuple2(
		A3(
			clampCell,
			grid.bZ,
			grid.bs,
			$author$project$Shapes$cellOf(box.aN.i)),
		A3(
			clampCell,
			grid.bZ,
			grid.bs,
			$author$project$Shapes$cellOf(box.aM.i)));
	var zFrom = _v0.a;
	var zTo = _v0.b;
	var _v1 = _Utils_Tuple2(
		A3(
			clampCell,
			grid.bY,
			grid.br,
			$author$project$Shapes$cellOf(box.aN.ja)),
		A3(
			clampCell,
			grid.bY,
			grid.br,
			$author$project$Shapes$cellOf(box.aM.ja)));
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
								var _v2 = $elm$core$Array$get$((((x * grid.br) + y) * grid.bs) + z, grid.b$);
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
			grid.bX,
			grid.bK,
			$author$project$Shapes$cellOf(box.aN.i6)),
		yFrom,
		zFrom,
		initial);
};
var $author$project$Shapes$foldWithin = F4($author$project$Shapes$foldWithin$);
var $author$project$Minimap$inBox$ = function (box, p) {
	return ((p.i6 - box.aN.i6) >= 0) && (((p.i6 - box.aM.i6) <= 0) && (((p.ja - box.aN.ja) >= 0) && (((p.ja - box.aM.ja) <= 0) && (((p.i - box.aN.i) >= 0) && ((p.i - box.aM.i) <= 0)))));
};
var $author$project$Minimap$inBox = F2($author$project$Minimap$inBox$);
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
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
var $author$project$Minimap$addFanImages$ = function (shapes, triangle, images) {
	return $author$project$Shapes$foldWithin$(
		{aM: triangle.aM, aN: triangle.aN},
		F2(
			function (index, acc) {
				var _v0 = $elm$core$Array$get$(index, shapes.bN);
				if (!_v0.$) {
					var point = _v0.a;
					if ($author$project$Minimap$inBox$(triangle, point.dT)) {
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
		(A2($elm$core$Basics$pow, a.i6 - b.i6, 2) + A2($elm$core$Basics$pow, a.ja - b.ja, 2)) + A2($elm$core$Basics$pow, a.i - b.i, 2));
};
var $author$project$Minimap$distance = F2($author$project$Minimap$distance$);
var $elm$core$Array$length = function (_v0) {
	var len = _v0.a;
	return len;
};
var $author$project$Minimap$maxFloat$ = function (a, b) {
	return ((a - b) > 0) ? a : b;
};
var $author$project$Minimap$maxFloat = F2($author$project$Minimap$maxFloat$);
var $elm$core$Basics$min$ = function (x, y) {
	return (_Utils_cmp(x, y) < 0) ? x : y;
};
var $elm$core$Basics$min = F2($elm$core$Basics$min$);
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
		left.b6 + $elm$core$Array$length(left.bN),
		right.b6 + $elm$core$Array$length(right.bN)) - 2;
	var at = F2(
		function (ray, j) {
			return $elm$core$Array$get$(j - ray.b6, ray.bN);
		});
	var add = F4(
		function (a, b, c, acc) {
			return ($author$project$Minimap$near$(a.dT, b.dT) && ($author$project$Minimap$near$(b.dT, c.dT) && $author$project$Minimap$near$(c.dT, a.dT))) ? A2(
				$elm$core$List$cons,
				{
					cr: a,
					ct: b,
					cu: c,
					aM: {
						i6: $author$project$Minimap$maxFloat$(
							a.dT.i6,
							$author$project$Minimap$maxFloat$(b.dT.i6, c.dT.i6)) + $author$project$Minimap$maxOffSurface,
						ja: $author$project$Minimap$maxFloat$(
							a.dT.ja,
							$author$project$Minimap$maxFloat$(b.dT.ja, c.dT.ja)) + $author$project$Minimap$maxOffSurface,
						i: $author$project$Minimap$maxFloat$(
							a.dT.i,
							$author$project$Minimap$maxFloat$(b.dT.i, c.dT.i)) + $author$project$Minimap$maxOffSurface
					},
					aN: {
						i6: $author$project$Minimap$minFloat$(
							a.dT.i6,
							$author$project$Minimap$minFloat$(b.dT.i6, c.dT.i6)) - $author$project$Minimap$maxOffSurface,
						ja: $author$project$Minimap$minFloat$(
							a.dT.ja,
							$author$project$Minimap$minFloat$(b.dT.ja, c.dT.ja)) - $author$project$Minimap$maxOffSurface,
						i: $author$project$Minimap$minFloat$(
							a.dT.i,
							$author$project$Minimap$minFloat$(b.dT.i, c.dT.i)) - $author$project$Minimap$maxOffSurface
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
		$elm$core$Basics$max$(left.b6, right.b6),
		triangles);
};
var $author$project$Minimap$between = F3($author$project$Minimap$between$);
var $elm$core$Basics$cos = _Basics_cos;
var $author$project$Surface$fanSpacing = 0.15;
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
				{E: nodeList, v: nodeListSize, A: jsArray});
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
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $elm$core$Basics$sin = _Basics_sin;
var $author$project$Minimap$fanTriangles = function (groups) {
	var pointsOf = function (ray) {
		return {
			b6: ray.fD,
			bN: $elm$core$Array$fromList(
				$elm$core$List$indexedMap$(
					F2(
						function (i, sample) {
							var distanceOnMap = (ray.fD + i) * $author$project$Surface$fanSpacing;
							return {
								z: sample.z,
								S: {
									i6: distanceOnMap * $elm$core$Basics$cos(ray.fs),
									ja: distanceOnMap * $elm$core$Basics$sin(ray.fs)
								},
								aa: sample.aa,
								dT: sample.dT
							};
						}),
					ray.$9))
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
var $author$project$Surface$cmul$ = function (p, q) {
	return {Q: (p.U * q.Q) + (p.Q * q.U), U: (p.U * q.U) - (p.Q * q.Q)};
};
var $author$project$Surface$cmul = F2($author$project$Surface$cmul$);
var $author$project$Surface$cscale$ = function (s, p) {
	return {Q: s * p.Q, U: s * p.U};
};
var $author$project$Surface$cscale = F2($author$project$Surface$cscale$);
var $elm$core$Maybe$andThen$ = function (callback, maybeValue) {
	if (!maybeValue.$) {
		var value = maybeValue.a;
		return callback(value);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $elm$core$Maybe$andThen = F2($elm$core$Maybe$andThen$);
var $elm$core$Basics$composeR$ = function (f, g, x) {
	return g(
		f(x));
};
var $elm$core$Basics$composeR = F3($elm$core$Basics$composeR$);
var $author$project$Surface$cabs = function (p) {
	return $elm$core$Basics$sqrt((p.U * p.U) + (p.Q * p.Q));
};
var $author$project$Surface$cadd$ = function (p, q) {
	return {Q: p.Q + q.Q, U: p.U + q.U};
};
var $author$project$Surface$cadd = F2($author$project$Surface$cadd$);
var $elm$core$Basics$clamp$ = function (low, high, number) {
	return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
};
var $elm$core$Basics$clamp = F3($elm$core$Basics$clamp$);
var $author$project$Surface$csub$ = function (p, q) {
	return {Q: p.Q - q.Q, U: p.U - q.U};
};
var $author$project$Surface$csub = F2($author$project$Surface$csub$);
var $author$project$Surface$distanceToSegment$ = function (p, q) {
	var d = $author$project$Surface$csub$(q, p);
	var lengthSquared = (d.U * d.U) + (d.Q * d.Q);
	var t = (lengthSquared < 1.0e-18) ? 0 : $elm$core$Basics$clamp$(0, 1, -(((p.U * d.U) + (p.Q * d.Q)) / lengthSquared));
	return $author$project$Surface$cabs(
		$author$project$Surface$cadd$(
			p,
			$author$project$Surface$cscale$(t, d)));
};
var $author$project$Surface$distanceToSegment = F2($author$project$Surface$distanceToSegment$);
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
var $author$project$Surface$edgeCount = function (piece) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$Array$length(flat.L);
	} else {
		var feature = piece.a;
		var _v1 = feature.r;
		if (!_v1.$) {
			return 4;
		} else {
			return 2;
		}
	}
};
var $author$project$Surface$edgeFractions$ = function (piece, edgeIndex) {
	var count = function () {
		if (!piece.$) {
			var flat = piece.a;
			var _v1 = $elm$core$Array$get$(edgeIndex, flat.L);
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
var $author$project$Surface$add$ = function (a, b) {
	return {i6: a.i6 + b.i6, ja: a.ja + b.ja, i: a.i + b.i};
};
var $author$project$Surface$add = F2($author$project$Surface$add$);
var $author$project$Surface$combine$ = function (a, p, b, q) {
	return {i6: (a * p.i6) + (b * q.i6), ja: (a * p.ja) + (b * q.ja), i: (a * p.i) + (b * q.i)};
};
var $author$project$Surface$combine = F4($author$project$Surface$combine$);
var $author$project$Surface$segLength = function (segment) {
	if (!segment.$) {
		var len = segment.a.Z;
		return len;
	} else {
		var len = segment.a.Z;
		return len;
	}
};
var $author$project$Surface$segS0 = function (segment) {
	if (!segment.$) {
		var s0 = segment.a.ap;
		return s0;
	} else {
		var s0 = segment.a.ap;
		return s0;
	}
};
var $author$project$Surface$clampFloat$ = function (low, high, x) {
	return ((x - low) < 0) ? low : (((x - high) > 0) ? high : x);
};
var $author$project$Surface$clampFloat = F3($author$project$Surface$clampFloat$);
var $author$project$Surface$segmentAt$ = function (segment, s) {
	if (!segment.$) {
		var dh = segment.a.av;
		var dr = segment.a.B;
		var h0 = segment.a.cE;
		var r0 = segment.a.bO;
		var len = segment.a.Z;
		var s0 = segment.a.ap;
		var t = $author$project$Surface$clampFloat$(0, len, s - s0);
		return {av: dh, B: dr, bo: h0 + (t * dh), f: r0 + (t * dr)};
	} else {
		var dir = segment.a.b3;
		var a0 = segment.a.W;
		var radius = segment.a.gq;
		var ch = segment.a.b0;
		var cr = segment.a.bz;
		var len = segment.a.Z;
		var s0 = segment.a.ap;
		var angle = a0 + ((dir * $author$project$Surface$clampFloat$(0, len, s - s0)) / radius);
		return {
			av: dir * $elm$core$Basics$cos(angle),
			B: (-dir) * $elm$core$Basics$sin(angle),
			bo: ch + (radius * $elm$core$Basics$sin(angle)),
			f: cr + (radius * $elm$core$Basics$cos(angle))
		};
	}
};
var $author$project$Surface$segmentAt = F2($author$project$Surface$segmentAt$);
var $author$project$Surface$profileAtHelper$ = function (segments, s) {
	profileAtHelper:
	while (true) {
		if (!segments.b) {
			return {av: 1, B: 0, bo: 0, f: 0};
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
	return $author$project$Surface$profileAtHelper$(feature.I, s);
};
var $author$project$Surface$profileAt = F2($author$project$Surface$profileAt$);
var $author$project$Surface$featurePoint$ = function (feature, theta, s) {
	var radial = $author$project$Surface$combine$(
		$elm$core$Basics$cos(theta),
		feature.ai,
		$elm$core$Basics$sin(theta),
		feature.aj);
	var p = $author$project$Surface$profileAt$(feature, s);
	return $author$project$Surface$add$(
		feature.w,
		$author$project$Surface$combine$(p.f, radial, p.bo, feature.X));
};
var $author$project$Surface$featurePoint = F3($author$project$Surface$featurePoint$);
var $author$project$Surface$flatPoint$ = function (flat, a, b) {
	return $author$project$Surface$add$(
		flat.w,
		$author$project$Surface$combine$(a, flat.aU, b, flat.aW));
};
var $author$project$Surface$flatPoint = F3($author$project$Surface$flatPoint$);
var $elm$core$Basics$pi = _Basics_pi;
var $author$project$Surface$sweepRange = function (feature) {
	var _v0 = feature.r;
	if (!_v0.$) {
		var to = _v0.a.ab;
		var from = _v0.a.P;
		return _Utils_Tuple2(from, to);
	} else {
		return _Utils_Tuple2(0, 2 * $elm$core$Basics$pi);
	}
};
var $author$project$Surface$tolerance = 1.0e-4;
var $author$project$Surface$edgeSample$ = function (piece, edgeIndex, t) {
	if (!piece.$) {
		var flat = piece.a;
		var _v1 = $elm$core$Array$get$(edgeIndex, flat.L);
		if (!_v1.$) {
			if (!_v1.a.$) {
				var by = _v1.a.a.a4;
				var bx = _v1.a.a.a3;
				var ay = _v1.a.a.a0;
				var ax = _v1.a.a.a$;
				return $elm$core$Maybe$Just(
					$author$project$Surface$flatPoint$(flat, ax + (t * (bx - ax)), ay + (t * (by - ay))));
			} else {
				var swept = _v1.a.a.aT;
				var a0 = _v1.a.a.W;
				var r = _v1.a.a.f;
				var cy = _v1.a.a.a6;
				var cx = _v1.a.a.a5;
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
					$author$project$Surface$profileAt$(feature, feature.k).f) - $author$project$Surface$tolerance) < 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, from + (t * (to - from)), feature.k));
			case 2:
				return $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, from, t * feature.k));
			case 3:
				return $elm$core$Maybe$Just(
					$author$project$Surface$featurePoint$(feature, to, t * feature.k));
			default:
				return $elm$core$Maybe$Nothing;
		}
	}
};
var $author$project$Surface$edgeSample = F3($author$project$Surface$edgeSample$);
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
var $author$project$Surface$holeEdges = function (piece) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$List$filterMap$(
			function (_v1) {
				var index = _v1.a;
				var edge = _v1.b;
				if (edge.$ === 1) {
					var swept = edge.a.aT;
					return (_Utils_cmp(swept, ((-2) * $elm$core$Basics$pi) + 1.0e-6) < 0) ? $elm$core$Maybe$Just(index) : $elm$core$Maybe$Nothing;
				} else {
					return $elm$core$Maybe$Nothing;
				}
			},
			$elm$core$Array$toIndexedList(flat.L));
	} else {
		return _List_Nil;
	}
};
var $author$project$Surface$wrapAngle = function (angle) {
	var turns = $elm$core$Basics$floor(angle / (2 * $elm$core$Basics$pi));
	return angle - ((turns * 2) * $elm$core$Basics$pi);
};
var $author$project$Surface$intersectWindows$ = function (first, second) {
	if (_Utils_cmp(first.fH, $elm$core$Basics$pi) > -1) {
		return second;
	} else {
		if (_Utils_cmp(second.fH, $elm$core$Basics$pi) > -1) {
			return first;
		} else {
			var offset = $author$project$Surface$wrapAngle((second.cv - first.cv) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
			var to = $elm$core$Basics$min$(first.fH, offset + second.fH);
			var from = $elm$core$Basics$max$(-first.fH, offset - second.fH);
			return {
				cv: first.cv + ((from + to) / 2),
				fH: $elm$core$Basics$max$(0, (to - from) / 2)
			};
		}
	}
};
var $author$project$Surface$intersectWindows = F2($author$project$Surface$intersectWindows$);
var $elm$core$Basics$composeL$ = function (g, f, x) {
	return g(
		f(x));
};
var $elm$core$Basics$composeL = F3($elm$core$Basics$composeL$);
var $elm$core$Basics$not = _Basics_not;
var $elm$core$List$all$ = function (isOkay, list) {
	return !$elm$core$List$any$(
		A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
		list);
};
var $elm$core$List$all = F2($elm$core$List$all$);
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Surface$isNewPlacement$ = function (child, placed) {
	return $elm$core$List$all$(
		function (other) {
			return (!_Utils_eq(other.aa, child.aa)) || (($author$project$Surface$cabs(
				$author$project$Surface$csub$(other.aq, child.aq)) > 1.0e-6) || (($author$project$Surface$cabs(
				$author$project$Surface$csub$(other.gh, child.gh)) > 1.0e-6) || (($elm$core$Basics$abs(
				$author$project$Surface$wrapAngle((other.fl.cv - child.fl.cv) + $elm$core$Basics$pi) - $elm$core$Basics$pi) > 1.0e-6) || ($elm$core$Basics$abs(
				$elm$core$Basics$min$($elm$core$Basics$pi, other.fl.fH) - $elm$core$Basics$min$($elm$core$Basics$pi, child.fl.fH)) > 1.0e-6))));
		},
		placed);
};
var $author$project$Surface$isNewPlacement = F2($author$project$Surface$isNewPlacement$);
var $author$project$Surface$isRigid = function (piece) {
	if (!piece.$) {
		return true;
	} else {
		var feature = piece.a;
		return (!_Utils_eq(feature.r, $elm$core$Maybe$Nothing)) && $elm$core$List$all$(
			function (segment) {
				if (!segment.$) {
					var dr = segment.a.B;
					return $elm$core$Basics$abs(dr) < 1.0e-9;
				} else {
					return false;
				}
			},
			feature.I);
	}
};
var $author$project$Surface$maxFloat$ = function (a, b) {
	return ((a - b) > 0) ? a : b;
};
var $author$project$Surface$maxFloat = F2($author$project$Surface$maxFloat$);
var $author$project$Surface$minimumRadius = 1.0e-3;
var $elm$core$Basics$atan2 = _Basics_atan2;
var $elm$core$Basics$e = _Basics_e;
var $elm$core$Basics$tan = _Basics_tan;
var $author$project$Surface$segmentSigma$ = function (segment, t) {
	if (!segment.$) {
		var dr = segment.a.B;
		var r0 = segment.a.bO;
		return ($elm$core$Basics$abs(dr) < 1.0e-9) ? (t / $author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0)) : (($elm$core$Basics$logBase$(
			$elm$core$Basics$e,
			$author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0 + (t * dr))) - $elm$core$Basics$logBase$(
			$elm$core$Basics$e,
			$author$project$Surface$maxFloat$($author$project$Surface$minimumRadius, r0))) / dr);
	} else {
		var len = segment.a.Z;
		var dir = segment.a.b3;
		var a0 = segment.a.W;
		var radius = segment.a.gq;
		var cr = segment.a.bz;
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
		feature.I);
	var beyond = (s < 0) ? (s / $author$project$Surface$maxFloat$(
		$author$project$Surface$minimumRadius,
		$author$project$Surface$profileAt$(feature, 0).f)) : (((s - feature.k) > 0) ? ((s - feature.k) / $author$project$Surface$maxFloat$(
		$author$project$Surface$minimumRadius,
		$author$project$Surface$profileAt$(feature, feature.k).f)) : 0);
	return inside + beyond;
};
var $author$project$Surface$sigmaAt = F2($author$project$Surface$sigmaAt$);
var $author$project$Surface$localChart$ = function (piece, a, b) {
	if (!piece.$) {
		return {Q: b, U: a};
	} else {
		var feature = piece.a;
		return {
			Q: feature.at * a,
			U: $author$project$Surface$sigmaAt$(feature, b)
		};
	}
};
var $author$project$Surface$localChart = F3($author$project$Surface$localChart$);
var $author$project$Surface$clampTheta$ = function (feature, theta) {
	var _v0 = feature.r;
	if (!_v0.$) {
		var to = _v0.a.ab;
		var from = _v0.a.P;
		var relative = $author$project$Surface$wrapAngle(theta - from);
		return (_Utils_cmp(relative, to - from) < 1) ? (from + relative) : ((_Utils_cmp(relative - (to - from), (2 * $elm$core$Basics$pi) - relative) < 0) ? to : from);
	} else {
		return $author$project$Surface$wrapAngle(theta);
	}
};
var $author$project$Surface$clampTheta = F2($author$project$Surface$clampTheta$);
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
		var by = edge.a.a4;
		var bx = edge.a.a3;
		var ay = edge.a.a0;
		var ax = edge.a.a$;
		var dy = by - ay;
		var dx = bx - ax;
		var t = $elm$core$Basics$clamp$(0, 1, (((a - ax) * dx) + ((b - ay) * dy)) / ((dx * dx) + (dy * dy)));
		return _Utils_Tuple2(ax + (t * dx), ay + (t * dy));
	} else {
		var swept = edge.a.aT;
		var a0 = edge.a.W;
		var r = edge.a.f;
		var cy = edge.a.a6;
		var cx = edge.a.a5;
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
var $author$project$Surface$closestOnSegment$ = function (segment, r, h) {
	if (!segment.$) {
		var dh = segment.a.av;
		var dr = segment.a.B;
		var h0 = segment.a.cE;
		var r0 = segment.a.bO;
		var len = segment.a.Z;
		var s0 = segment.a.ap;
		return s0 + $elm$core$Basics$clamp$(0, len, ((r - r0) * dr) + ((h - h0) * dh));
	} else {
		var dir = segment.a.b3;
		var a0 = segment.a.W;
		var radius = segment.a.gq;
		var ch = segment.a.b0;
		var cr = segment.a.bz;
		var len = segment.a.Z;
		var s0 = segment.a.ap;
		var swept = len / radius;
		var relative = $author$project$Surface$wrapAngle(
			dir * (A2($elm$core$Basics$atan2, h - ch, r - cr) - a0));
		return (_Utils_cmp(relative, swept) < 1) ? (s0 + (relative * radius)) : ((_Utils_cmp(relative - swept, (2 * $elm$core$Basics$pi) - relative) < 0) ? (s0 + len) : s0);
	}
};
var $author$project$Surface$closestOnSegment = F3($author$project$Surface$closestOnSegment$);
var $author$project$Surface$closestOnProfile$ = function (feature, r, h) {
	return $elm$core$List$foldl$(
		F2(
			function (segment, _v0) {
				var bestS = _v0.a;
				var bestDistance = _v0.b;
				var s = $author$project$Surface$closestOnSegment$(segment, r, h);
				var p = $author$project$Surface$segmentAt$(segment, s);
				var distance = A2($elm$core$Basics$pow, p.f - r, 2) + A2($elm$core$Basics$pow, p.bo - h, 2);
				return (_Utils_cmp(distance, bestDistance) < 0) ? _Utils_Tuple2(s, distance) : _Utils_Tuple2(bestS, bestDistance);
			}),
		_Utils_Tuple2(0, 1 / 0),
		feature.I).a;
};
var $author$project$Surface$closestOnProfile = F3($author$project$Surface$closestOnProfile$);
var $author$project$Surface$dot$ = function (a, b) {
	return ((a.i6 * b.i6) + (a.ja * b.ja)) + (a.i * b.i);
};
var $author$project$Surface$dot = F2($author$project$Surface$dot$);
var $author$project$Surface$sub$ = function (a, b) {
	return {i6: a.i6 - b.i6, ja: a.ja - b.ja, i: a.i - b.i};
};
var $author$project$Surface$sub = F2($author$project$Surface$sub$);
var $author$project$Surface$locateOnEdge$ = function (piece, edgeIndex, point) {
	if (!piece.$) {
		var flat = piece.a;
		var local = $author$project$Surface$sub$(point, flat.w);
		var _v1 = $elm$core$Array$get$(edgeIndex, flat.L);
		if (!_v1.$) {
			var edge = _v1.a;
			var _v2 = $author$project$Surface$closestOnEdge2d$(
				edge,
				$author$project$Surface$dot$(local, flat.aU),
				$author$project$Surface$dot$(local, flat.aW));
			var a = _v2.a;
			var b = _v2.b;
			return {cr: a, ct: b};
		} else {
			return {cr: 0, ct: 0};
		}
	} else {
		var feature = piece.a;
		var local = $author$project$Surface$sub$(point, feature.w);
		var x = $author$project$Surface$dot$(local, feature.ai);
		var y = $author$project$Surface$dot$(local, feature.aj);
		var profileParam = function (theta) {
			return $author$project$Surface$closestOnProfile$(
				feature,
				(x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta)),
				$author$project$Surface$dot$(local, feature.X));
		};
		var _v3 = $author$project$Surface$sweepRange(feature);
		var from = _v3.a;
		var to = _v3.b;
		switch (edgeIndex) {
			case 0:
				return {
					cr: $author$project$Surface$clampTheta$(
						feature,
						A2($elm$core$Basics$atan2, y, x)),
					ct: 0
				};
			case 1:
				return {
					cr: $author$project$Surface$clampTheta$(
						feature,
						A2($elm$core$Basics$atan2, y, x)),
					ct: feature.k
				};
			case 2:
				return {
					cr: from,
					ct: profileParam(from)
				};
			default:
				return {
					cr: to,
					ct: profileParam(to)
				};
		}
	}
};
var $author$project$Surface$locateOnEdge = F3($author$project$Surface$locateOnEdge$);
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
	var denominator = (q.U * q.U) + (q.Q * q.Q);
	return {Q: ((p.Q * q.U) - (p.U * q.Q)) / denominator, U: ((p.U * q.U) + (p.Q * q.Q)) / denominator};
};
var $author$project$Surface$cdiv = F2($author$project$Surface$cdiv$);
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Surface$holeOnMap$ = function (piece, placement) {
	if (!piece.$) {
		var flat = piece.a;
		return $elm$core$Maybe$andThen$(
			function (edge) {
				if (edge.$ === 1) {
					var r = edge.a.f;
					var cy = edge.a.a6;
					var cx = edge.a.a5;
					return $elm$core$Maybe$Just(
						{
							cv: $author$project$Surface$cadd$(
								$author$project$Surface$cmul$(
									placement.aq,
									{Q: cy, U: cx}),
								placement.gh),
							gq: r * $author$project$Surface$cabs(placement.aq)
						});
				} else {
					return $elm$core$Maybe$Nothing;
				}
			},
			$elm$core$Maybe$andThen$(
				function (index) {
					return $elm$core$Array$get$(index, flat.L);
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
		$author$project$Surface$cmul$(placement.aq, chart),
		placement.gh);
};
var $author$project$Surface$placeOnMap = F2($author$project$Surface$placeOnMap$);
var $author$project$Surface$placeChild$ = function (parent, parentPiece, edgeIndex, childIndex, childEdge, childPiece, distance, window) {
	var parentOutput = function (p) {
		var located = $author$project$Surface$locateOnEdge$(parentPiece, edgeIndex, p);
		return $author$project$Surface$placeOnMap$(
			parent,
			$author$project$Surface$localChart$(parentPiece, located.cr, located.ct));
	};
	var childChart = function (p) {
		var located = $author$project$Surface$locateOnEdge$(childPiece, childEdge, p);
		return $author$project$Surface$localChart$(childPiece, located.cr, located.ct);
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
					bC: distance,
					hD: $author$project$Surface$holeOnMap$(
						childPiece,
						{gh: offset, aq: scale_}),
					gh: offset,
					aa: childIndex,
					aq: scale_,
					fl: window
				});
		} else {
			return $elm$core$Maybe$Nothing;
		}
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Surface$placeChild = F8($author$project$Surface$placeChild$);
var $elm$core$List$sortBy = _List_sortBy;
var $author$project$Surface$subtractWindow$ = function (cut, window) {
	if (_Utils_cmp(cut.fH, $elm$core$Basics$pi) > -1) {
		return _List_Nil;
	} else {
		if (_Utils_cmp(window.fH, $elm$core$Basics$pi) > -1) {
			return _List_fromArray(
				[
					{cv: cut.cv + $elm$core$Basics$pi, fH: $elm$core$Basics$pi - cut.fH}
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
			var offset = $author$project$Surface$wrapAngle((cut.cv - window.cv) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
			return $elm$core$List$map$(
				function (_v0) {
					var from = _v0.a;
					var to = _v0.b;
					return {cv: window.cv + ((from + to) / 2), fH: (to - from) / 2};
				},
				$elm$core$List$foldl$(
					F2(
						function (turns, intervals) {
							return A2(
								remove,
								_Utils_Tuple2((offset - cut.fH) + ((turns * 2) * $elm$core$Basics$pi), (offset + cut.fH) + ((turns * 2) * $elm$core$Basics$pi)),
								intervals);
						}),
					_List_fromArray(
						[
							_Utils_Tuple2(-window.fH, window.fH)
						]),
					_List_fromArray(
						[-1, 0, 1])));
		}
	}
};
var $author$project$Surface$subtractWindow = F2($author$project$Surface$subtractWindow$);
var $author$project$Surface$fullWindow = {cv: 0, fH: $elm$core$Basics$pi};
var $author$project$Surface$windowOf = function (points) {
	var _v0 = $elm$core$List$map$(
		function (p) {
			return A2($elm$core$Basics$atan2, p.Q, p.U);
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
		return (_Utils_cmp(high - low, (2 * $elm$core$Basics$pi) - 1.0e-3) > -1) ? $author$project$Surface$fullWindow : {cv: (low + high) / 2, fH: (high - low) / 2};
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
					return $.dS;
				},
				function ($) {
					return $.bC;
				}),
			queue);
		if (!_v0.b) {
			return _Utils_Tuple2(
				$elm$core$List$reverse(placed),
				curved);
		} else {
			var route = _v0.a.e0;
			var enteredThrough = _v0.a.eC;
			var placement = _v0.a.dS;
			var rest = _v0.b;
			var _v1 = $elm$core$Array$get$(placement.aa, pieces);
			if (!_v1.$) {
				var parentPiece = _v1.a;
				var edgeOnMap = function (edgeIndex) {
					return $elm$core$List$map$(
						function (p) {
							var located = $author$project$Surface$locateOnEdge$(parentPiece, edgeIndex, p);
							return $author$project$Surface$placeOnMap$(
								placement,
								$author$project$Surface$localChart$(parentPiece, located.cr, located.ct));
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
									$elm$core$Array$get$(placement.aa, seams)));
							if (!_v3.$) {
								var _v4 = _v3.a;
								var childIndex = _v4.a;
								var childEdge = _v4.b;
								var points = edgeOnMap(edgeIndex);
								var visible = $elm$core$List$filter$(
									function (window) {
										return window.fH > 1.0e-6;
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
												placement.fl,
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
														$elm$core$Basics$max$(distance, placement.bC),
														window);
													if (!_v7.$) {
														var child = _v7.a;
														return ((_Utils_cmp(
															$elm$core$List$length(p),
															$author$project$Surface$maxPlacements) < 0) && $author$project$Surface$isNewPlacement$(child, p)) ? _Utils_Tuple3(
															A2(
																$elm$core$List$cons,
																{
																	eC: childEdge,
																	dS: child,
																	e0: A2($elm$core$List$cons, childIndex, route)
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
var $author$project$Surface$finishGroup = function (rays) {
	var firsts = $elm$core$List$map$(
		function (ray) {
			return $elm$core$Basics$isInfinite(ray.aJ) ? 1000000 : $elm$core$Basics$max$(
				0,
				$elm$core$Basics$floor(ray.aJ / $author$project$Surface$fanSpacing) - 2);
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
					fs: ray.fs,
					fD: first,
					$9: $elm$core$List$drop$(first, ray.$9)
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
				var from = $author$project$Surface$wrapAngle((window.cv - window.fH) - $author$project$Surface$fanMargin);
				return _Utils_Tuple2(from, from + (2 * (window.fH + $author$project$Surface$fanMargin)));
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
var $author$project$Surface$lengthOf = function (a) {
	return $elm$core$Basics$sqrt(
		$author$project$Surface$dot$(a, a));
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
						$author$project$Surface$sub$(p.dT, q.dT));
				}),
			first,
			second));
};
var $author$project$Surface$spread = F2($author$project$Surface$spread$);
var $elm$core$Basics$acos = _Basics_acos;
var $author$project$Surface$cross$ = function (a, b) {
	return {i6: (a.ja * b.i) - (a.i * b.ja), ja: (a.i * b.i6) - (a.i6 * b.i), i: (a.i6 * b.ja) - (a.ja * b.i6)};
};
var $author$project$Surface$cross = F2($author$project$Surface$cross$);
var $author$project$Surface$edgeTangent2d$ = function (edge, a, b) {
	if (!edge.$) {
		var by = edge.a.a4;
		var bx = edge.a.a3;
		var ay = edge.a.a0;
		var ax = edge.a.a$;
		var l = $elm$core$Basics$sqrt(
			A2($elm$core$Basics$pow, bx - ax, 2) + A2($elm$core$Basics$pow, by - ay, 2));
		return _Utils_Tuple2((bx - ax) / l, (by - ay) / l);
	} else {
		var swept = edge.a.aT;
		var cy = edge.a.a6;
		var cx = edge.a.a5;
		var dir = (swept < 0) ? (-1) : 1;
		var angle = A2($elm$core$Basics$atan2, b - cy, a - cx);
		return _Utils_Tuple2(
			(-dir) * $elm$core$Basics$sin(angle),
			dir * $elm$core$Basics$cos(angle));
	}
};
var $author$project$Surface$edgeTangent2d = F3($author$project$Surface$edgeTangent2d$);
var $author$project$Surface$featureBasis$ = function (feature, theta, s) {
	var radial = $author$project$Surface$combine$(
		$elm$core$Basics$cos(theta),
		feature.ai,
		$elm$core$Basics$sin(theta),
		feature.aj);
	var p = $author$project$Surface$profileAt$(feature, s);
	return {
		ag: $author$project$Surface$combine$(p.B, radial, p.av, feature.X),
		ah: $author$project$Surface$combine$(
			-$elm$core$Basics$sin(theta),
			feature.ai,
			$elm$core$Basics$cos(theta),
			feature.aj),
		m: $author$project$Surface$combine$(p.av, radial, -p.B, feature.X),
		G: $author$project$Surface$add$(
			feature.w,
			$author$project$Surface$combine$(p.f, radial, p.bo, feature.X))
	};
};
var $author$project$Surface$featureBasis = F3($author$project$Surface$featureBasis$);
var $author$project$Surface$scale$ = function (s, a) {
	return {i6: s * a.i6, ja: s * a.ja, i: s * a.i};
};
var $author$project$Surface$scale = F2($author$project$Surface$scale$);
var $author$project$Surface$edgeFrame$ = function (piece, edgeIndex, a, b) {
	if (!piece.$) {
		var flat = piece.a;
		var _v1 = function () {
			var _v2 = $elm$core$Array$get$(edgeIndex, flat.L);
			if (!_v2.$) {
				var edge = _v2.a;
				return $author$project$Surface$edgeTangent2d$(edge, a, b);
			} else {
				return _Utils_Tuple2(1, 0);
			}
		}();
		var tx = _v1.a;
		var ty = _v1.b;
		var tangent = $author$project$Surface$combine$(tx, flat.aU, ty, flat.aW);
		return {
			ca: $author$project$Surface$cross$(flat.m, tangent),
			iK: tangent
		};
	} else {
		var feature = piece.a;
		var basis = $author$project$Surface$featureBasis$(feature, a, b);
		switch (edgeIndex) {
			case 0:
				return {ca: basis.ag, iK: basis.ah};
			case 1:
				return {
					ca: $author$project$Surface$scale$(-1, basis.ag),
					iK: basis.ah
				};
			case 2:
				return {ca: basis.ah, iK: basis.ag};
			default:
				return {
					ca: $author$project$Surface$scale$(-1, basis.ah),
					iK: basis.ag
				};
		}
	}
};
var $author$project$Surface$edgeFrame = F4($author$project$Surface$edgeFrame$);
var $author$project$Surface$headingToVec$ = function (frame, heading) {
	return $author$project$Surface$combine$(
		$elm$core$Basics$cos(heading),
		frame.bD,
		$elm$core$Basics$sin(heading),
		frame.bE);
};
var $author$project$Surface$headingToVec = F2($author$project$Surface$headingToVec$);
var $author$project$Surface$tangentFrame$ = function (piece, a, b) {
	if (!piece.$) {
		var flat = piece.a;
		return {
			bD: flat.aU,
			bE: flat.aW,
			m: flat.m,
			G: $author$project$Surface$flatPoint$(flat, a, b)
		};
	} else {
		var feature = piece.a;
		var basis = $author$project$Surface$featureBasis$(feature, a, b);
		return {
			bD: basis.ag,
			bE: $author$project$Surface$scale$(feature.at, basis.ah),
			m: basis.m,
			G: basis.G
		};
	}
};
var $author$project$Surface$tangentFrame = F3($author$project$Surface$tangentFrame$);
var $author$project$Surface$vecToHeading$ = function (frame, direction) {
	return A2(
		$elm$core$Basics$atan2,
		$author$project$Surface$dot$(direction, frame.bE),
		$author$project$Surface$dot$(direction, frame.bD));
};
var $author$project$Surface$vecToHeading = F2($author$project$Surface$vecToHeading$);
var $author$project$Surface$crossSeam$ = function (piece, edgeIndex, point, other, otherIndex, otherEdge) {
	var frame = $author$project$Surface$tangentFrame$(piece, point.cr, point.ct);
	var located = $author$project$Surface$locateOnEdge$(other, otherEdge, frame.G);
	var otherFrame = $author$project$Surface$tangentFrame$(other, located.cr, located.ct);
	var direction = $author$project$Surface$headingToVec$(frame, point.e);
	var _v0 = $author$project$Surface$edgeFrame$(other, otherEdge, located.cr, located.ct);
	var inward = _v0.ca;
	var tangent = _v0.iK;
	var along = $author$project$Surface$dot$(direction, tangent);
	var across = $elm$core$Basics$sqrt(
		$elm$core$Basics$max$(1.0e-12, 1 - (along * along)));
	return {
		cr: located.cr,
		ct: located.ct,
		e: $author$project$Surface$vecToHeading$(
			otherFrame,
			$author$project$Surface$combine$(along, tangent, across, inward)),
		aa: otherIndex
	};
};
var $author$project$Surface$crossSeam = F6($author$project$Surface$crossSeam$);
var $author$project$Surface$emitSamples$ = function (context, travelled, until, at, index, samples) {
	emitSamples:
	while (true) {
		if (((index - context.aE) <= 0) && (((index * $author$project$Surface$fanSpacing) - until) <= 1.0e-9)) {
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
var $author$project$Surface$sweepStart = function (feature) {
	var _v0 = feature.r;
	if (!_v0.$) {
		var from = _v0.a.P;
		return from;
	} else {
		return 0;
	}
};
var $author$project$Surface$featureShape = function (feature) {
	var _v0 = feature.I;
	_v0$2:
	while (true) {
		if (_v0.b) {
			if (!_v0.a.$) {
				if (!_v0.b.b) {
					var dr = _v0.a.a.B;
					var r0 = _v0.a.a.bO;
					return ($elm$core$Basics$abs(dr) < 1.0e-9) ? $author$project$Surface$Cylinder(r0) : $author$project$Surface$Revolved;
				} else {
					break _v0$2;
				}
			} else {
				if (!_v0.b.b) {
					var radius = _v0.a.a.gq;
					var ch = _v0.a.a.b0;
					var cr = _v0.a.a.bz;
					return (($elm$core$Basics$abs(cr) < 1.0e-9) && (_Utils_cmp(
						$author$project$Surface$sweepRange(feature).b - $author$project$Surface$sweepStart(feature),
						$elm$core$Basics$pi + 1.0e-9) < 1)) ? $author$project$Surface$Sphere$(
						$author$project$Surface$add$(
							feature.w,
							$author$project$Surface$scale$(ch, feature.X)),
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
		]) : (((after.a - feature.k) > 0) ? _List_fromArray(
		[
			_Utils_Tuple2(
			1,
			A3(fraction, before.a, after.a, feature.k))
		]) : _List_Nil);
	var sweepViolations = function () {
		var _v3 = feature.r;
		if (!_v3.$) {
			var to = _v3.a.ab;
			var from = _v3.a.P;
			return ((after.b - from) < 0) ? _List_fromArray(
				[
					_Utils_Tuple2(
					2,
					A3(fraction, before.b, after.b, from))
				]) : (((after.b - to) > 0) ? _List_fromArray(
				[
					_Utils_Tuple2(
					3,
					A3(fraction, before.b, after.b, to))
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
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
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
var $author$project$Surface$onArc$ = function (a0, swept, angle) {
	var dir = (swept < 0) ? (-1) : 1;
	return ($author$project$Surface$wrapAngle(dir * (angle - a0)) - $elm$core$Basics$abs(swept)) <= 1.0e-9;
};
var $author$project$Surface$onArc = F3($author$project$Surface$onArc$);
var $author$project$Surface$rayExit$ = function (edge, px, py, dx, dy) {
	if (!edge.$) {
		var by = edge.a.a4;
		var bx = edge.a.a3;
		var ay = edge.a.a0;
		var ax = edge.a.a$;
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
		var swept = edge.a.aT;
		var a0 = edge.a.W;
		var r = edge.a.f;
		var cy = edge.a.a6;
		var cx = edge.a.a5;
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
		flat.L).b;
};
var $author$project$Surface$flatExit = F5($author$project$Surface$flatExit$);
var $author$project$Surface$insideSweep$ = function (feature, theta) {
	var _v0 = feature.r;
	if (!_v0.$) {
		var to = _v0.a.ab;
		var from = _v0.a.P;
		return ($author$project$Surface$wrapAngle(theta - from) - (to - from)) <= 1.0e-9;
	} else {
		return true;
	}
};
var $author$project$Surface$insideSweep = F2($author$project$Surface$insideSweep$);
var $author$project$Surface$leavePole$ = function (feature, state) {
	var p = $author$project$Surface$profileAt$(feature, state.a);
	var atStart = (state.a - $author$project$Surface$tolerance) < 0;
	var atEnd = (state.a - (feature.k - $author$project$Surface$tolerance)) > 0;
	if ((($elm$core$Basics$abs(p.f) - $author$project$Surface$tolerance) < 0) && (atStart || atEnd)) {
		var outwardSign = atStart ? p.B : (-p.B);
		var basis = $author$project$Surface$featureBasis$(feature, state.b, state.a);
		var direction = $author$project$Surface$combine$(
			$elm$core$Basics$cos(state.l),
			basis.ag,
			$elm$core$Basics$sin(state.l) * feature.at,
			basis.ah);
		var theta = A2(
			$elm$core$Basics$atan2,
			$author$project$Surface$dot$(direction, feature.aj),
			$author$project$Surface$dot$(direction, feature.ai)) + ((outwardSign < 0) ? $elm$core$Basics$pi : 0);
		return $author$project$Surface$insideSweep$(feature, theta) ? $elm$core$Result$Ok(
			{
				l: atStart ? 0 : $elm$core$Basics$pi,
				a: state.a,
				b: $author$project$Surface$clampTheta$(feature, theta)
			}) : $elm$core$Result$Err(direction);
	} else {
		return $elm$core$Result$Ok(state);
	}
};
var $author$project$Surface$leavePole = F2($author$project$Surface$leavePole$);
var $author$project$Surface$profileParamUnclamped$ = function (feature, r, h) {
	var s = $author$project$Surface$closestOnProfile$(feature, r, h);
	var along = function (end) {
		var p = $author$project$Surface$profileAt$(feature, end);
		return (end + ((r - p.f) * p.B)) + ((h - p.bo) * p.av);
	};
	return (s <= 1.0e-9) ? $elm$core$Basics$min$(
		0,
		along(0)) : ((_Utils_cmp(s, feature.k - 1.0e-9) > -1) ? $elm$core$Basics$max$(
		feature.k,
		along(feature.k)) : s);
};
var $author$project$Surface$profileParamUnclamped = F3($author$project$Surface$profileParamUnclamped$);
var $author$project$Surface$localCoordinatesUnclamped$ = function (piece, point) {
	if (!piece.$) {
		var flat = piece.a;
		var local = $author$project$Surface$sub$(point, flat.w);
		return {
			cr: $author$project$Surface$dot$(local, flat.aU),
			ct: $author$project$Surface$dot$(local, flat.aW)
		};
	} else {
		var feature = piece.a;
		var local = $author$project$Surface$sub$(point, feature.w);
		var x = $author$project$Surface$dot$(local, feature.ai);
		var y = $author$project$Surface$dot$(local, feature.aj);
		var rawTheta = A2($elm$core$Basics$atan2, y, x);
		var theta = function () {
			var _v1 = feature.r;
			if (!_v1.$) {
				var to = _v1.a.ab;
				var from = _v1.a.P;
				var middle = (from + to) / 2;
				return (middle + $author$project$Surface$wrapAngle((rawTheta - middle) + $elm$core$Basics$pi)) - $elm$core$Basics$pi;
			} else {
				return rawTheta;
			}
		}();
		return {
			cr: theta,
			ct: $author$project$Surface$profileParamUnclamped$(
				feature,
				(x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta)),
				$author$project$Surface$dot$(local, feature.X))
		};
	}
};
var $author$project$Surface$localCoordinatesUnclamped = F2($author$project$Surface$localCoordinatesUnclamped$);
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
var $author$project$Surface$cexp = function (p) {
	var magnitude = A2($elm$core$Basics$pow, $elm$core$Basics$e, p.U);
	return {
		Q: magnitude * $elm$core$Basics$sin(p.Q),
		U: magnitude * $elm$core$Basics$cos(p.Q)
	};
};
var $author$project$Surface$pieceExponent = function (piece) {
	if (!piece.$) {
		return 0;
	} else {
		var feature = piece.a;
		return (($elm$core$Basics$abs(
			$author$project$Surface$profileAt$(feature, feature.k).f) - $author$project$Surface$tolerance) < 0) ? (-1) : (((($elm$core$Basics$abs(
			$author$project$Surface$profileAt$(feature, 0).f) - $author$project$Surface$tolerance) < 0) || _Utils_eq(feature.r, $elm$core$Maybe$Nothing)) ? 1 : 0);
	}
};
var $author$project$Surface$mapChart$ = function (piece, a, b) {
	var exponent = $author$project$Surface$pieceExponent(piece);
	var chart = $author$project$Surface$localChart$(piece, a, b);
	return (!exponent) ? chart : $author$project$Surface$cexp(
		$author$project$Surface$cscale$(exponent, chart));
};
var $author$project$Surface$mapChart = F3($author$project$Surface$mapChart$);
var $author$project$Surface$maxSeamCrossings = 200;
var $author$project$Surface$minFloat$ = function (a, b) {
	return ((a - b) < 0) ? a : b;
};
var $author$project$Surface$minFloat = F2($author$project$Surface$minFloat$);
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
var $author$project$Surface$projectOntoFeature$ = function (feature, point) {
	var local = $author$project$Surface$sub$(point, feature.w);
	var x = $author$project$Surface$dot$(local, feature.ai);
	var y = $author$project$Surface$dot$(local, feature.aj);
	var theta = $author$project$Surface$clampTheta$(
		feature,
		A2($elm$core$Basics$atan2, y, x));
	var r = (x * $elm$core$Basics$cos(theta)) + (y * $elm$core$Basics$sin(theta));
	return _Utils_Tuple2(
		theta,
		$author$project$Surface$closestOnProfile$(
			feature,
			r,
			$author$project$Surface$dot$(local, feature.X)));
};
var $author$project$Surface$projectOntoFeature = F2($author$project$Surface$projectOntoFeature$);
var $elm$core$Basics$modBy = _Basics_modBy;
var $author$project$Surface$rayCrossings$ = function (edge, a, b) {
	if (!edge.$) {
		var by = edge.a.a4;
		var bx = edge.a.a3;
		var ay = edge.a.a0;
		var ax = edge.a.a$;
		return ((!_Utils_eq(
			_Utils_cmp(ay, b) > 0,
			_Utils_cmp(by, b) > 0)) && (_Utils_cmp(a, ax + (((b - ay) / (by - ay)) * (bx - ax))) < 0)) ? 1 : 0;
	} else {
		var swept = edge.a.aT;
		var a0 = edge.a.W;
		var r = edge.a.f;
		var cy = edge.a.a6;
		var cx = edge.a.a5;
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
			flat.L));
};
var $author$project$Surface$insideFlat = F3($author$project$Surface$insideFlat$);
var $author$project$Surface$projectOntoFlat$ = function (flat, point) {
	var local = $author$project$Surface$sub$(point, flat.w);
	var b = $author$project$Surface$dot$(local, flat.aW);
	var a = $author$project$Surface$dot$(local, flat.aU);
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
		flat.L).a;
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
											{cr: a, ct: b, aa: index},
											distance)) : best;
								} else {
									return $elm$core$Maybe$Just(
										_Utils_Tuple2(
											{cr: a, ct: b, aa: index},
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
		l: ((-$elm$core$Basics$sin(state.l)) * p.B) / r,
		a: $elm$core$Basics$cos(state.l),
		b: (feature.at * $elm$core$Basics$sin(state.l)) / r
	};
};
var $author$project$Surface$derivative = F2($author$project$Surface$derivative$);
var $author$project$Surface$rk4$ = function (feature, h, state) {
	var offset = F2(
		function (k, f) {
			return {l: state.l + (f * k.l), a: state.a + (f * k.a), b: state.b + (f * k.b)};
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
	return {l: state.l + ((h / 6) * (((k1.l + (2 * k2.l)) + (2 * k3.l)) + k4.l)), a: state.a + ((h / 6) * (((k1.a + (2 * k2.a)) + (2 * k3.a)) + k4.a)), b: state.b + ((h / 6) * (((k1.b + (2 * k2.b)) + (2 * k3.b)) + k4.b))};
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
						return _Utils_Tuple2(partial.a - feature.k, rate.a);
					case 2:
						return _Utils_Tuple2(
							partial.b - $author$project$Surface$sweepStart(feature),
							rate.b);
					default:
						return _Utils_Tuple2(
							partial.b - $author$project$Surface$sweepRange(feature).b,
							rate.b);
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
		z: $author$project$Surface$mapChart$(piece, a, b),
		aa: pieceIndex,
		dT: $author$project$Surface$piecePoint$(piece, a, b)
	};
};
var $author$project$Surface$sampleAt = F4($author$project$Surface$sampleAt$);
var $author$project$Surface$crossTrace$ = function (context, crossings, pieceIndex, edgeIndex, edgePoint, travelled, index, trace) {
	var _v31 = _Utils_Tuple2(
		$elm$core$Array$get$(pieceIndex, context.u),
		$elm$core$Maybe$andThen$(
			$elm$core$Basics$identity,
			$elm$core$Maybe$andThen$(
				$elm$core$Array$get(edgeIndex),
				$elm$core$Array$get$(pieceIndex, context.aS))));
	if ((!_v31.a.$) && (!_v31.b.$)) {
		var piece = _v31.a.a;
		var _v32 = _v31.b.a;
		var otherIndex = _v32.a;
		var otherEdge = _v32.b;
		var _v33 = $elm$core$Array$get$(otherIndex, context.u);
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
	var ds = $elm$core$Basics$cos(state.l);
	var dTheta = (feature.at * $elm$core$Basics$sin(state.l)) / radius;
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
							_Utils_Tuple2(1, (feature.k - state.a) / ds)) : $elm$core$Maybe$Nothing
						]),
					function () {
						var _v30 = feature.r;
						if (!_v30.$) {
							var to = _v30.a.ab;
							var from = _v30.a.P;
							return _List_fromArray(
								[
									((dTheta + 1.0e-12) < 0) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(2, (from - state.b) / dTheta)) : $elm$core$Maybe$Nothing,
									(dTheta > 1.0e-12) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(3, (to - state.b) / dTheta)) : $elm$core$Maybe$Nothing
								]);
						} else {
							return _List_Nil;
						}
					}()))));
	var until = $author$project$Surface$minFloat$(
		context.aE * $author$project$Surface$fanSpacing,
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
			return $author$project$Surface$sampleAt$(piece, pieceIndex, state.b + (t * dTheta), state.a + (t * ds));
		},
		index,
		trace.$9);
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
					return _Utils_Tuple2(state.b + (t * dTheta), 0);
				case 1:
					return _Utils_Tuple2(state.b + (t * dTheta), feature.k);
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
			{cr: a, ct: b, e: state.l, aa: pieceIndex},
			travelled + t,
			nextIndex,
			_Utils_update(
				trace,
				{$9: samples}));
	} else {
		return _Utils_update(
			trace,
			{$9: samples});
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
		if ((index - context.aE) > 0) {
			return trace;
		} else {
			var _v16 = $author$project$Surface$leavePole$(feature, state_);
			if (_v16.$ === 1) {
				var direction = _v16.a;
				var _v17 = $author$project$Surface$nearestExcluding$(
					pieceIndex,
					$author$project$Surface$add$(
						$author$project$Surface$featurePoint$(feature, state_.b, state_.a),
						$author$project$Surface$scale$(1.0e-7, direction)),
					context.u);
				if (!_v17.$) {
					var next = _v17.a;
					var _v18 = $elm$core$Array$get$(next.aa, context.u);
					if (!_v18.$) {
						var nextPiece = _v18.a;
						return $author$project$Surface$traceStep$(
							context,
							crossings + 1,
							{
								cr: next.cr,
								ct: next.ct,
								e: $author$project$Surface$vecToHeading$(
									$author$project$Surface$tangentFrame$(nextPiece, next.cr, next.ct),
									direction),
								aa: next.aa
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
							$9: A2(
								$elm$core$List$cons,
								$author$project$Surface$sampleAt$(piece, pieceIndex, state.b, state.a),
								trace.$9)
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
										{a: feature.k});
								case 2:
									return _Utils_update(
										partial,
										{
											b: $author$project$Surface$sweepStart(feature)
										});
								default:
									return _Utils_update(
										partial,
										{
											b: $author$project$Surface$sweepRange(feature).b
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
								{cr: clamped.b, ct: clamped.a, e: clamped.l, aa: pieceIndex},
								travelled + (h * fraction),
								index,
								trace);
						}
					} else {
						var $temp$state_ = function () {
							var _v22 = feature.r;
							if (!_v22.$) {
								return next;
							} else {
								return _Utils_update(
									next,
									{
										b: $author$project$Surface$wrapAngle(next.b)
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
	var offset = $author$project$Surface$sub$(center, feature.w);
	var basis = $author$project$Surface$featureBasis$(feature, state.b, state.a);
	var e1 = $author$project$Surface$scale$(
		1 / radius,
		$author$project$Surface$sub$(basis.G, center));
	var e2 = $author$project$Surface$combine$(
		$elm$core$Basics$cos(state.l),
		basis.ag,
		$elm$core$Basics$sin(state.l) * feature.at,
		basis.ah);
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
				A2(crossing, feature.X, end.bo));
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
						feature.ai,
						$elm$core$Basics$cos(theta),
						feature.aj),
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
							A2(profileEdge, 1, feature.k)
						]),
					function () {
						var _v15 = feature.r;
						if (!_v15.$) {
							var to = _v15.a.ab;
							var from = _v15.a.P;
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
		context.aE * $author$project$Surface$fanSpacing,
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
				z: $author$project$Surface$mapChart$(piece, local.cr, local.ct),
				aa: pieceIndex,
				dT: position
			};
		},
		index,
		trace.$9);
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
						$author$project$Surface$clampTheta$(feature, local.cr),
						0);
				case 1:
					return _Utils_Tuple2(
						$author$project$Surface$clampTheta$(feature, local.cr),
						feature.k);
				case 2:
					return _Utils_Tuple2(
						$author$project$Surface$sweepStart(feature),
						$elm$core$Basics$clamp$(0, feature.k, local.ct));
				default:
					return _Utils_Tuple2(
						$author$project$Surface$sweepRange(feature).b,
						$elm$core$Basics$clamp$(0, feature.k, local.ct));
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
				cr: a,
				ct: b,
				e: $author$project$Surface$vecToHeading$(
					$author$project$Surface$tangentFrame$(piece, a, b),
					$author$project$Surface$combine$(
						-$elm$core$Basics$sin(angle),
						e1,
						$elm$core$Basics$cos(angle),
						e2)),
				aa: pieceIndex
			},
			travelled + (radius * angle),
			nextIndex,
			_Utils_update(
				trace,
				{$9: samples}));
	} else {
		return _Utils_update(
			trace,
			{$9: samples});
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
	if (((index - context.aE) > 0) || ((crossings - $author$project$Surface$maxSeamCrossings) > 0)) {
		return trace;
	} else {
		var _v0 = $elm$core$Array$get$(point.aa, context.u);
		if (!_v0.$) {
			var piece = _v0.a;
			var newTrace = (((travelled - trace.aJ) < 0) && (!_Utils_eq(
				$elm$core$Array$get$(point.aa, context.c8),
				$elm$core$Maybe$Just(true)))) ? _Utils_update(
				trace,
				{aJ: travelled}) : trace;
			if (!piece.$) {
				var flat = piece.a;
				var dy = $elm$core$Basics$sin(point.e);
				var dx = $elm$core$Basics$cos(point.e);
				var exit = $author$project$Surface$flatExit$(flat, point.cr, point.ct, dx, dy);
				var until = $author$project$Surface$minFloat$(
					context.aE * $author$project$Surface$fanSpacing,
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
									$author$project$Surface$sampleAt$(piece, point.aa, point.cr + (t * dx), point.ct + (t * dy)),
									samples);
								i = $temp$i;
								samples = $temp$samples;
								continue emit;
							} else {
								return _Utils_Tuple2(i, samples);
							}
						}
					});
				var _v2 = A2(emit, index, newTrace.$9);
				var nextIndex = _v2.a;
				var samples_ = _v2.b;
				if (!exit.$) {
					var _v4 = exit.a;
					var edgeIndex = _v4.a;
					var t = _v4.b;
					return $author$project$Surface$crossTrace$(
						context,
						crossings,
						point.aa,
						edgeIndex,
						_Utils_update(
							point,
							{cr: point.cr + (t * dx), ct: point.ct + (t * dy)}),
						travelled + t,
						nextIndex,
						_Utils_update(
							newTrace,
							{$9: samples_}));
				} else {
					return _Utils_update(
						newTrace,
						{$9: samples_});
				}
			} else {
				var feature = piece.a;
				var state = {l: point.e, a: point.ct, b: point.cr};
				var _v7 = $author$project$Surface$featureShape(feature);
				switch (_v7.$) {
					case 0:
						var radius = _v7.a;
						return $author$project$Surface$traceCylinder$(context, crossings, point.aa, piece, feature, radius, state, travelled, index, newTrace);
					case 1:
						var center = _v7.a;
						var radius = _v7.b;
						return (($author$project$Surface$profileAt$(feature, state.a).f - $author$project$Surface$tolerance) < 0) ? $author$project$Surface$traceFeature$(context, crossings, point.aa, piece, feature, state, travelled, index, newTrace) : $author$project$Surface$traceSphere$(context, crossings, point.aa, piece, feature, center, radius, state, travelled, index, newTrace);
					default:
						return $author$project$Surface$traceFeature$(context, crossings, point.aa, piece, feature, state, travelled, index, newTrace);
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
				{e: (walker.e + angle) - ($elm$core$Basics$pi / 2)}),
			0,
			0,
			{aJ: 1 / 0, $9: _List_Nil});
		return {
			fs: angle,
			aJ: trace.aJ,
			$9: $elm$core$List$reverse(trace.$9)
		};
	};
	var refine = F3(
		function (depth, left, right) {
			if ((depth > 0) && (_Utils_cmp(
				$author$project$Surface$spread$(left.$9, right.$9),
				$author$project$Surface$fanGap) > 0)) {
				var middle = traceAt((left.fs + right.fs) / 2);
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
	var seams = _v1.aS;
	var pieces = _v1.u;
	var _v2 = $elm$core$Array$get$(walker.aa, pieces);
	if (!_v2.$) {
		var piece = _v2.a;
		var _v3 = function () {
			if ($author$project$Surface$isRigid(piece)) {
				var rho = function () {
					if (!piece.$) {
						return 1;
					} else {
						var feature = piece.a;
						return $author$project$Surface$profileAt$(feature, walker.ct).f;
					}
				}();
				var scale_ = $author$project$Surface$cmul$(
					{Q: rho, U: 0},
					{
						Q: -$elm$core$Basics$sin(walker.e),
						U: $elm$core$Basics$cos(walker.e)
					});
				var chart = $author$project$Surface$localChart$(piece, walker.cr, walker.ct);
				var start = {
					bC: 0,
					hD: $author$project$Surface$holeOnMap$(
						piece,
						{
							gh: $author$project$Surface$cscale$(
								-1,
								$author$project$Surface$cmul$(scale_, chart)),
							aq: scale_
						}),
					gh: $author$project$Surface$cscale$(
						-1,
						$author$project$Surface$cmul$(scale_, chart)),
					aa: walker.aa,
					aq: scale_,
					fl: $author$project$Surface$fullWindow
				};
				return $author$project$Surface$flattenHelper$(
					radius,
					pieces,
					seams,
					_List_fromArray(
						[
							{
							eC: -1,
							dS: start,
							e0: _List_fromArray(
								[walker.aa])
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
			hw: $author$project$Surface$traceFan$(
				{
					aE: $elm$core$Basics$ceiling(radius / $author$project$Surface$fanSpacing),
					u: pieces,
					c8: $elm$core$Array$map$($author$project$Surface$isRigid, pieces),
					aS: seams
				},
				walker,
				curved),
			ig: placements
		};
	} else {
		return {hw: _List_Nil, ig: _List_Nil};
	}
};
var $author$project$Surface$mapAround = F3($author$project$Surface$mapAround$);
var $author$project$Minimap$angleBetween$ = function (a, b) {
	var d = (a - b) + $elm$core$Basics$pi;
	return (d - ((2 * $elm$core$Basics$pi) * $elm$core$Basics$floor(d / (2 * $elm$core$Basics$pi)))) - $elm$core$Basics$pi;
};
var $author$project$Minimap$angleBetween = F2($author$project$Minimap$angleBetween$);
var $author$project$Minimap$placementImage$ = function (radius, point, placement) {
	if (!_Utils_eq(placement.aa, point.aa)) {
		return $elm$core$Maybe$Nothing;
	} else {
		var w = $author$project$Surface$placeOnMap$(placement, point.z);
		var lengthSquared = (w.U * w.U) + (w.Q * w.Q);
		var inWindow = (_Utils_cmp(placement.fl.fH, $elm$core$Basics$pi) > -1) || (_Utils_cmp(
			$elm$core$Basics$abs(
				$author$project$Minimap$angleBetween$(
					A2($elm$core$Basics$atan2, w.Q, w.U),
					placement.fl.cv)),
			placement.fl.fH + 0.002) < 1);
		var behindHole = function () {
			var _v0 = placement.hD;
			if (!_v0.$) {
				var hole = _v0.a;
				var t = (lengthSquared > 0) ? $elm$core$Basics$clamp$(0, 1, ((hole.cv.U * w.U) + (hole.cv.Q * w.Q)) / lengthSquared) : 0;
				return _Utils_cmp(
					A2($elm$core$Basics$pow, (t * w.U) - hole.cv.U, 2) + A2($elm$core$Basics$pow, (t * w.Q) - hole.cv.Q, 2),
					hole.gq * hole.gq) < 0;
			} else {
				return false;
			}
		}();
		return (inWindow && ((!behindHole) && (_Utils_cmp(
			lengthSquared,
			A2($elm$core$Basics$pow, 1.2 * radius, 2)) < 0))) ? $elm$core$Maybe$Just(
			{i6: w.U, ja: w.Q}) : $elm$core$Maybe$Nothing;
	}
};
var $author$project$Minimap$placementImage = F3($author$project$Minimap$placementImage$);
var $ianmackenzie$elm_geometry$Point3d$toMeters = function (_v0) {
	var coordinates = _v0;
	return coordinates;
};
var $ianmackenzie$elm_units$Quantity$Quantity = $elm$core$Basics$identity;
var $ianmackenzie$elm_units$Length$meters = function (numMeters) {
	return numMeters;
};
var $author$project$Minimap$viewRadius = $ianmackenzie$elm_units$Length$meters(4);
var $ianmackenzie$elm_geometry$Geometry$Types$Point3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Point3d$fromMeters = function (coordinates) {
	return coordinates;
};
var $author$project$Surface$toPoint = function (v) {
	return $ianmackenzie$elm_geometry$Point3d$fromMeters(v);
};
var $author$project$Surface$getPiece$ = function (index, _v0) {
	var surface = _v0;
	return $elm$core$Array$get$(index, surface.u);
};
var $author$project$Surface$getPiece = F2($author$project$Surface$getPiece$);
var $author$project$Surface$withFrame$ = function (func, _v0, surface) {
	var point = _v0;
	return $elm$core$Maybe$map$(
		function (piece) {
			return func(
				$author$project$Surface$tangentFrame$(piece, point.cr, point.ct));
		},
		$author$project$Surface$getPiece$(point.aa, surface));
};
var $author$project$Surface$withFrame = F3($author$project$Surface$withFrame$);
var $author$project$Surface$worldPosition = $author$project$Surface$withFrame(
	A2(
		$elm$core$Basics$composeR,
		function ($) {
			return $.G;
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
				return (($author$project$Minimap$distance$(point.dT, player) - (radius + 0.05)) <= 0) ? $elm$core$List$foldl$(
					$author$project$Minimap$addImage,
					_List_Nil,
					$elm$core$List$filterMap$(
						A2($author$project$Minimap$placementImage, radius, point),
						layout.ig)) : _List_Nil;
			},
			shapes.bN);
		return $elm$core$List$foldl$(
			$author$project$Minimap$addFanImages(shapes),
			throughPlacements,
			$author$project$Minimap$fanTriangles(layout.hw));
	} else {
		return $elm$core$Array$empty;
	}
};
var $author$project$Minimap$imagesAround = F3($author$project$Minimap$imagesAround$);
var $ianmackenzie$elm_units$Pixels$inPixels = function (_v0) {
	var numPixels = _v0;
	return numPixels;
};
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
var $elm$core$Tuple$pair$ = function (a, b) {
	return _Utils_Tuple2(a, b);
};
var $elm$core$Tuple$pair = F2($elm$core$Tuple$pair$);
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
					$author$project$Minimap$distance$(p.dT, q.dT),
					a,
					qImages),
				$author$project$Minimap$closestMatch$(
					$author$project$Minimap$distance$(p.dT, r.dT),
					a,
					rImages));
			if ((!_v3.a.$) && (!_v3.b.$)) {
				var b = _v3.a.a;
				var c = _v3.b.a;
				return (($author$project$Minimap$mapDistance$(b, c) - (($author$project$Minimap$maxStretch * $author$project$Minimap$distance$(q.dT, r.dT)) + $author$project$Minimap$sameImage)) <= 0) ? $elm$core$Maybe$Just(
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
	var ux = (((b.i6 - a.i6) / length) * width) / 2;
	var uy = (((b.ja - a.ja) / length) * width) / 2;
	var corner = F3(
		function (s, t, p) {
			return {i6: (p.i6 + (s * ux)) - (t * uy), ja: (p.ja + (s * uy)) + (t * ux)};
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
						$author$project$Minimap$distance$(p.dT, q.dT),
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
			$elm$core$Array$get$(index, shapes.bN),
			$elm$core$Array$get$(index, images));
	};
	return {
		bb: $elm$core$List$concatMap$(
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
			shapes.$8),
		aY: $elm$core$List$concatMap$(
			function (wall) {
				return $author$project$Minimap$wallQuads$(
					(($author$project$Minimap$wallWidth / sizeInPixels) * 2) * radius,
					$elm$core$List$filterMap$(withImages, wall));
			},
			shapes.aY)
	};
};
var $author$project$Minimap$drawingAround = F3($author$project$Minimap$drawingAround$);
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
							millimeters(a.i6),
							A2(
								$elm$core$List$cons,
								millimeters(a.ja),
								A2(
									$elm$core$List$cons,
									millimeters(b.i6),
									A2(
										$elm$core$List$cons,
										millimeters(b.ja),
										A2(
											$elm$core$List$cons,
											millimeters(c.i6),
											A2(
												$elm$core$List$cons,
												millimeters(c.ja),
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
				encodeTriangles(drawing.bb)),
				_Utils_Tuple2(
				'walls',
				encodeTriangles(drawing.aY))
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
				$elm$json$Json$Encode$int(point.aa)),
				_Utils_Tuple2(
				'a',
				$elm$json$Json$Encode$float(point.cr)),
				_Utils_Tuple2(
				'b',
				$elm$json$Json$Encode$float(point.ct)),
				_Utils_Tuple2(
				'heading',
				$elm$json$Json$Encode$float(point.e))
			]));
};
var $author$project$Shapes$empty = {
	b8: {b$: $elm$core$Array$empty, bK: 0, br: 0, bs: 0, bX: 0, bY: 0, bZ: 0},
	$8: _List_Nil,
	bN: $elm$core$Array$empty,
	aY: _List_Nil
};
var $author$project$WorldShapes$pavings = _List_fromArray(
	[
		{
		bN: _List_fromArray(
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
		aB: _List_fromArray(
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
		bN: _List_fromArray(
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
		aB: _List_fromArray(
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
		bN: _List_fromArray(
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
		aB: _List_fromArray(
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
		bN: _List_fromArray(
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
		aB: _List_fromArray(
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
		bN: _List_fromArray(
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
		aB: _List_fromArray(
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
var $author$project$Shapes$distance$ = function (a, b) {
	return $elm$core$Basics$sqrt(
		(A2($elm$core$Basics$pow, a.i6 - b.i6, 2) + A2($elm$core$Basics$pow, a.ja - b.ja, 2)) + A2($elm$core$Basics$pow, a.i - b.i, 2));
};
var $author$project$Shapes$distance = F2($author$project$Shapes$distance$);
var $author$project$Shapes$lerp$ = function (t, a, b) {
	return {i6: a.i6 + (t * (b.i6 - a.i6)), ja: a.ja + (t * (b.ja - a.ja)), i: a.i + (t * (b.i - a.i))};
};
var $author$project$Shapes$lerp = F3($author$project$Shapes$lerp$);
var $author$project$Shapes$wallStep = 0.1;
var $author$project$Shapes$alongWall = function (points) {
	if (points.b && points.b.b) {
		var first = points.a;
		var _v1 = points.b;
		var second = _v1.a;
		var rest = _v1.b;
		var steps = $elm$core$Basics$max$(
			1,
			$elm$core$Basics$ceiling(
				$author$project$Shapes$distance$(first, second) / $author$project$Shapes$wallStep));
		return _Utils_ap(
			$elm$core$List$map$(
				function (i) {
					return $author$project$Shapes$lerp$(i / steps, first, second);
				},
				$elm$core$List$range$(0, steps - 1)),
			$author$project$Shapes$alongWall(
				A2($elm$core$List$cons, second, rest)));
	} else {
		return points;
	}
};
var $elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var $elm$core$Elm$JsArray$slice = _JsArray_slice;
var $elm$core$Array$appendHelpBuilder$ = function (tail, builder) {
	var tailLen = $elm$core$Elm$JsArray$length(tail);
	var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(builder.A)) - tailLen;
	var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, builder.A, tail);
	return (notAppended < 0) ? {
		E: A2(
			$elm$core$List$cons,
			$elm$core$Array$Leaf(appended),
			builder.E),
		v: builder.v + 1,
		A: A3($elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
	} : ((!notAppended) ? {
		E: A2(
			$elm$core$List$cons,
			$elm$core$Array$Leaf(appended),
			builder.E),
		v: builder.v + 1,
		A: $elm$core$Elm$JsArray$empty
	} : {E: builder.E, v: builder.v, A: appended});
};
var $elm$core$Array$appendHelpBuilder = F2($elm$core$Array$appendHelpBuilder$);
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
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
		E: A3($elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		v: (len / $elm$core$Array$branchFactor) | 0,
		A: tail
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
var $author$project$Surface$fromPoint = function (point) {
	return $ianmackenzie$elm_geometry$Point3d$toMeters(point);
};
var $author$project$Surface$chartCoordinate$ = function (surface, pieceIndex, point) {
	var _v0 = $author$project$Surface$getPiece$(pieceIndex, surface);
	if (!_v0.$) {
		var piece = _v0.a;
		var local = $author$project$Surface$localCoordinatesUnclamped$(
			piece,
			$author$project$Surface$fromPoint(point));
		return $author$project$Surface$mapChart$(piece, local.cr, local.ct);
	} else {
		return {Q: 0, U: 0};
	}
};
var $author$project$Surface$chartCoordinate = F3($author$project$Surface$chartCoordinate$);
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $author$project$Shapes$fromTuple = function (_v0) {
	var x = _v0.a;
	var y = _v0.b;
	var z = _v0.c;
	return {i6: x, ja: y, i: z};
};
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
var $author$project$Shapes$gridOf = function (points) {
	var cells = $elm$core$List$map$(
		function (p) {
			return _Utils_Tuple3(
				$author$project$Shapes$cellOf(p.dT.i6),
				$author$project$Shapes$cellOf(p.dT.ja),
				$author$project$Shapes$cellOf(p.dT.i));
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
		b$: $elm$core$List$foldl$(
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
		bK: nx,
		br: ny,
		bs: nz,
		bX: x0,
		bY: y0,
		bZ: z0
	};
};
var $ianmackenzie$elm_geometry$Point3d$meters$ = function (x, y, z) {
	return {i6: x, ja: y, i: z};
};
var $ianmackenzie$elm_geometry$Point3d$meters = F3($ianmackenzie$elm_geometry$Point3d$meters$);
var $author$project$Surface$nearest$ = function (point, _v0) {
	var surface = _v0;
	var p = $author$project$Surface$fromPoint(point);
	return $elm$core$Maybe$map$(
		$elm$core$Tuple$first,
		$elm$core$Array$foldl$(
			F2(
				function (piece, _v1) {
					var index = _v1.a;
					var best = _v1.b;
					var _v2 = $author$project$Surface$projectOntoPiece$(piece, p);
					var a = _v2.a;
					var b = _v2.b;
					var position = $author$project$Surface$piecePoint$(piece, a, b);
					var distance = $author$project$Surface$lengthOf(
						$author$project$Surface$sub$(position, p));
					return _Utils_Tuple2(
						index + 1,
						function () {
							if (!best.$) {
								var _v4 = best.a;
								var bestDistance = _v4.b;
								return (_Utils_cmp(distance, bestDistance) < 0) ? $elm$core$Maybe$Just(
									_Utils_Tuple2(
										{cr: a, ct: b, aa: index, dT: position},
										distance)) : best;
							} else {
								return $elm$core$Maybe$Just(
									_Utils_Tuple2(
										{cr: a, ct: b, aa: index, dT: position},
										distance));
							}
						}());
				}),
			_Utils_Tuple2(0, $elm$core$Maybe$Nothing),
			surface.u).b);
};
var $author$project$Surface$nearest = F2($author$project$Surface$nearest$);
var $author$project$Surface$nearestPiece$ = function (point, surface) {
	return $elm$core$Maybe$map$(
		function ($) {
			return $.aa;
		},
		$author$project$Surface$nearest$(point, surface));
};
var $author$project$Surface$nearestPiece = F2($author$project$Surface$nearestPiece$);
var $ianmackenzie$elm_geometry$Geometry$Types$Direction3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Direction3d$unsafe = function (components) {
	return components;
};
var $author$project$Surface$toDirection = function (v) {
	return $ianmackenzie$elm_geometry$Direction3d$unsafe(v);
};
var $author$project$Surface$nearestPoint$ = function (point, surface) {
	return $elm$core$Maybe$andThen$(
		function (_v0) {
			var b = _v0.ct;
			var a = _v0.cr;
			var piece = _v0.aa;
			return $elm$core$Maybe$map$(
				function (piece_) {
					var frame = $author$project$Surface$tangentFrame$(piece_, a, b);
					return {
						eS: $author$project$Surface$toDirection(frame.m),
						dT: $author$project$Surface$toPoint(frame.G)
					};
				},
				$author$project$Surface$getPiece$(piece, surface));
		},
		$author$project$Surface$nearest$(point, surface));
};
var $author$project$Surface$nearestPoint = F2($author$project$Surface$nearestPoint$);
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
var $author$project$Shapes$pavingEdge = 0.2;
var $elm$core$Array$push$ = function (a, array) {
	var tail = array.d;
	return $elm$core$Array$unsafeReplaceTail$(
		A2($elm$core$Elm$JsArray$push, a, tail),
		array);
};
var $elm$core$Array$push = F2($elm$core$Array$push$);
var $author$project$Shapes$split$ = function (snap, _v0, state) {
	var i = _v0.a;
	var j = _v0.b;
	var k = _v0.c;
	var at = function (index) {
		return $elm$core$Maybe$withDefault$(
			{i6: 0, ja: 0, i: 0},
			$elm$core$Array$get$(index, state.bN));
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
				var _v2 = $elm$core$Dict$get$(key, state.bJ);
				if (!_v2.$) {
					var existing = _v2.a;
					return _Utils_Tuple2(existing, state);
				} else {
					var index = $elm$core$Array$length(state.bN);
					return _Utils_Tuple2(
						index,
						_Utils_update(
							state,
							{
								bJ: $elm$core$Dict$insert$(key, index, state.bJ),
								bN: $elm$core$Array$push$(
									snap(
										$author$project$Shapes$lerp$(
											0.5,
											at(a),
											at(b))),
									state.bN)
							}));
				}
			}();
			var m = _v1.a;
			var withMidpoint = _v1.b;
			return $author$project$Shapes$split$(
				snap,
				_Utils_Tuple3(m, b, c),
				$author$project$Shapes$split$(
					snap,
					_Utils_Tuple3(a, m, c),
					withMidpoint));
		});
	return (_Utils_cmp(
		$elm$core$Basics$max$(
			dij,
			$elm$core$Basics$max$(djk, dki)),
		$author$project$Shapes$pavingEdge) < 1) ? _Utils_update(
		state,
		{
			aB: A2(
				$elm$core$List$cons,
				_Utils_Tuple3(i, j, k),
				state.aB)
		}) : (((_Utils_cmp(dij, djk) > -1) && (_Utils_cmp(dij, dki) > -1)) ? A3(halve, i, j, k) : ((_Utils_cmp(djk, dki) > -1) ? A3(halve, j, k, i) : A3(halve, k, i, j)));
};
var $author$project$Shapes$split = F3($author$project$Shapes$split$);
var $author$project$Shapes$prepare$ = function (surface, walls, pavings) {
	var snap = function (p) {
		var _v5 = $author$project$Surface$nearestPoint$(
			$ianmackenzie$elm_geometry$Point3d$meters$(p.i6, p.ja, p.i),
			surface);
		if (!_v5.$) {
			var position = _v5.a.dT;
			return $ianmackenzie$elm_geometry$Point3d$toMeters(position);
		} else {
			return p;
		}
	};
	var onPiece = function (p) {
		var point = $ianmackenzie$elm_geometry$Point3d$meters$(p.i6, p.ja, p.i);
		return $elm$core$Maybe$map$(
			function (piece) {
				return {
					z: $author$project$Surface$chartCoordinate$(surface, piece, point),
					aa: piece,
					dT: p
				};
			},
			$author$project$Surface$nearestPiece$(point, surface));
	};
	var _v0 = $elm$core$List$foldl$(
		F2(
			function (paving, _v1) {
				var pointsSoFar = _v1.a;
				var trianglesSoFar = _v1.b;
				var withCorners = $elm$core$Array$append$(
					pointsSoFar,
					$elm$core$Array$fromList(
						$elm$core$List$map$(
							A2($elm$core$Basics$composeR, $author$project$Shapes$fromTuple, snap),
							paving.bN)));
				var offset = $elm$core$Array$length(pointsSoFar);
				return function (state) {
					return _Utils_Tuple2(state.bN, state.aB);
				}(
					$elm$core$List$foldl$(
						F2(
							function (_v2, state) {
								var i = _v2.a;
								var j = _v2.b;
								var k = _v2.c;
								return $author$project$Shapes$split$(
									snap,
									_Utils_Tuple3(i + offset, j + offset, k + offset),
									state);
							}),
						{bJ: $elm$core$Dict$empty, bN: withCorners, aB: trianglesSoFar},
						paving.aB));
			}),
		_Utils_Tuple2($elm$core$Array$empty, _List_Nil),
		pavings);
	var points = _v0.a;
	var triangles = _v0.b;
	var _v3 = $elm$core$List$foldl$(
		F2(
			function (wall, _v4) {
				var pointsSoFar = _v4.a;
				var wallsSoFar = _v4.b;
				var added = $elm$core$List$map$(
					snap,
					$author$project$Shapes$alongWall(
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
		_Utils_Tuple2(points, _List_Nil),
		walls);
	var allPoints = _v3.a;
	var wallIndices = _v3.b;
	var shapePoints = $elm$core$Array$map$(
		function (p) {
			return $elm$core$Maybe$withDefault$(
				{
					z: {Q: 0, U: 0},
					aa: -1,
					dT: p
				},
				onPiece(p));
		},
		allPoints);
	return {
		b8: $author$project$Shapes$gridOf(shapePoints),
		$8: triangles,
		bN: shapePoints,
		aY: wallIndices
	};
};
var $author$project$Shapes$prepare = F3($author$project$Shapes$prepare$);
var $author$project$Surface$FeaturePiece = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$FlatPiece = function (a) {
	return {$: 0, a: a};
};
var $author$project$Surface$Surface = $elm$core$Basics$identity;
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
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $ianmackenzie$elm_geometry$Frame3d$originPoint = function (_v0) {
	var properties = _v0;
	return properties.dO;
};
var $ianmackenzie$elm_geometry$Point2d$toMeters = function (_v0) {
	var coordinates = _v0;
	return coordinates;
};
var $ianmackenzie$elm_geometry$Frame3d$xDirection = function (_v0) {
	var properties = _v0;
	return properties.eb;
};
var $ianmackenzie$elm_geometry$Frame3d$yDirection = function (_v0) {
	var properties = _v0;
	return properties.ec;
};
var $ianmackenzie$elm_geometry$Frame3d$zDirection = function (_v0) {
	var properties = _v0;
	return properties.fo;
};
var $author$project$Surface$buildFeature = function (spec) {
	var start = $ianmackenzie$elm_geometry$Point2d$toMeters(spec.c5.bQ);
	var ez = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$zDirection(spec.bG));
	var ey = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$yDirection(spec.bG));
	var ex = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$Frame3d$xDirection(spec.bG));
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
						var end = segment.a.aH;
						var e = $ianmackenzie$elm_geometry$Point2d$toMeters(end);
						var len = $elm$core$Basics$sqrt(
							A2($elm$core$Basics$pow, e.i6 - point.i6, 2) + A2($elm$core$Basics$pow, e.ja - point.ja, 2));
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								$author$project$Surface$LineSeg(
									{av: (e.ja - point.ja) / len, B: (e.i6 - point.i6) / len, cE: point.ja, Z: len, bO: point.i6, ap: s0}),
								acc),
							s0 + len,
							e);
					} else {
						var center = segment.a.cv;
						var end = segment.a.aH;
						var e = $ianmackenzie$elm_geometry$Point2d$toMeters(end);
						var c = $ianmackenzie$elm_geometry$Point2d$toMeters(center);
						var radius = $elm$core$Basics$sqrt(
							A2($elm$core$Basics$pow, point.i6 - c.i6, 2) + A2($elm$core$Basics$pow, point.ja - c.ja, 2));
						var a1 = A2($elm$core$Basics$atan2, e.ja - c.ja, e.i6 - c.i6);
						var a0 = A2($elm$core$Basics$atan2, point.ja - c.ja, point.i6 - c.i6);
						var delta = $author$project$Surface$wrapAngle((a1 - a0) + $elm$core$Basics$pi) - $elm$core$Basics$pi;
						var len = $elm$core$Basics$abs(delta) * radius;
						return _Utils_Tuple3(
							A2(
								$elm$core$List$cons,
								$author$project$Surface$ArcSeg(
									{
										W: a0,
										b0: c.ja,
										bz: c.i6,
										b3: (delta < 0) ? (-1) : 1,
										Z: len,
										gq: radius,
										ap: s0
									}),
								acc),
							s0 + len,
							e);
					}
				}),
			_Utils_Tuple3(_List_Nil, 0, start),
			spec.c5.I));
	var segments = _v0.a;
	var length = _v0.b;
	var feature = {
		at: 1,
		ai: ex,
		aj: ey,
		X: ez,
		k: length,
		w: $author$project$Surface$fromPoint(
			$ianmackenzie$elm_geometry$Frame3d$originPoint(spec.bG)),
		I: segments,
		r: function () {
			var _v4 = spec.r;
			if (!_v4.$) {
				return $elm$core$Maybe$Nothing;
			} else {
				var to = _v4.a.ab;
				var from = _v4.a.P;
				return $elm$core$Maybe$Just(
					{
						P: $ianmackenzie$elm_units$Angle$inRadians(from),
						ab: $ianmackenzie$elm_units$Angle$inRadians(to)
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
				at: ($author$project$Surface$dot$(
					$author$project$Surface$cross$(basis.m, basis.ag),
					basis.ah) < 0) ? (-1) : 1
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
			var start = edge.a.bQ;
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
						{a$: a.i6, a0: a.ja, a3: b.i6, a4: b.ja});
				} else {
					var sweptAngle = edge.a.e8;
					var center = edge.a.cv;
					var start = edge.a.bQ;
					var s = $ianmackenzie$elm_geometry$Point2d$toMeters(start);
					var c = $ianmackenzie$elm_geometry$Point2d$toMeters(center);
					return $author$project$Surface$ArcEdge(
						{
							W: A2($elm$core$Basics$atan2, s.ja - c.ja, s.i6 - c.i6),
							a5: c.i6,
							a6: c.ja,
							f: $elm$core$Basics$sqrt(
								A2($elm$core$Basics$pow, s.i6 - c.i6, 2) + A2($elm$core$Basics$pow, s.ja - c.ja, 2)),
							aT: $ianmackenzie$elm_units$Angle$inRadians(sweptAngle)
						});
				}
			}),
		loop,
		nextStarts);
};
var $author$project$Surface$edgeIsDegenerate = function (edge) {
	if (!edge.$) {
		var by = edge.a.a4;
		var bx = edge.a.a3;
		var ay = edge.a.a0;
		var ax = edge.a.a$;
		return _Utils_cmp(
			$elm$core$Basics$sqrt(
				A2($elm$core$Basics$pow, bx - ax, 2) + A2($elm$core$Basics$pow, by - ay, 2)),
			$author$project$Surface$tolerance) < 0;
	} else {
		var swept = edge.a.aT;
		var r = edge.a.f;
		return _Utils_cmp(
			$elm$core$Basics$abs(r * swept),
			$author$project$Surface$tolerance) < 0;
	}
};
var $ianmackenzie$elm_geometry$SketchPlane3d$originPoint = function (_v0) {
	var properties = _v0;
	return properties.dO;
};
var $ianmackenzie$elm_geometry$SketchPlane3d$xDirection = function (_v0) {
	var properties = _v0;
	return properties.eb;
};
var $ianmackenzie$elm_geometry$SketchPlane3d$yDirection = function (_v0) {
	var properties = _v0;
	return properties.ec;
};
var $author$project$Surface$buildFlat = function (spec) {
	var v = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$SketchPlane3d$yDirection(spec.ck));
	var u = $author$project$Surface$fromDirection(
		$ianmackenzie$elm_geometry$SketchPlane3d$xDirection(spec.ck));
	var origin = $author$project$Surface$fromPoint(
		$ianmackenzie$elm_geometry$SketchPlane3d$originPoint(spec.ck));
	var edges = $elm$core$List$concatMap$($author$project$Surface$buildLoop, spec.dk);
	return $elm$core$List$any$($author$project$Surface$edgeIsDegenerate, edges) ? $elm$core$Result$Err($author$project$Surface$DegenerateFlatEdge) : $elm$core$Result$Ok(
		{
			L: $elm$core$Array$fromList(edges),
			m: $author$project$Surface$cross$(u, v),
			w: origin,
			aU: u,
			aW: v
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
var $author$project$Surface$combineMaybes = function (maybes) {
	return $elm$core$List$foldr$(
		F2(
			function (maybe, acc) {
				return $elm$core$Maybe$map2$($elm$core$List$cons, maybe, acc);
			}),
		$elm$core$Maybe$Just(_List_Nil),
		maybes);
};
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
var $author$project$Surface$findSeams = function (pieces) {
	var samples = function (_v9) {
		var pieceIndex = _v9.a;
		var edgeIndex = _v9.b;
		var _v8 = $elm$core$Array$get$(pieceIndex, pieces);
		if (!_v8.$) {
			var piece = _v8.a;
			return $author$project$Surface$combineMaybes(
				$elm$core$List$map$(
					A2($author$project$Surface$edgeSample, piece, edgeIndex),
					_List_fromArray(
						[0, 0.25, 0.5, 0.75, 1])));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	};
	var liesOn = F2(
		function (_v7, points) {
			var pieceIndex = _v7.a;
			var edgeIndex = _v7.b;
			var _v6 = $elm$core$Array$get$(pieceIndex, pieces);
			if (!_v6.$) {
				var piece = _v6.a;
				return $elm$core$List$all$(
					function (point) {
						var located = $author$project$Surface$locateOnEdge$(piece, edgeIndex, point);
						return _Utils_cmp(
							$author$project$Surface$lengthOf(
								$author$project$Surface$sub$(
									$author$project$Surface$piecePoint$(piece, located.cr, located.ct),
									point)),
							$author$project$Surface$tolerance) < 0;
					},
					points);
			} else {
				return false;
			}
		});
	var describe = function (_v5) {
		var pieceIndex = _v5.a;
		var edgeIndex = _v5.b;
		return 'edge ' + ($elm$core$String$fromInt(edgeIndex) + (' of piece ' + $elm$core$String$fromInt(pieceIndex)));
	};
	var allEdges = $elm$core$List$concatMap$(
		function (_v4) {
			var index = _v4.a;
			var piece = _v4.b;
			return $elm$core$List$map$(
				$elm$core$Tuple$pair(index),
				$elm$core$List$range$(
					0,
					$author$project$Surface$edgeCount(piece) - 1));
		},
		$elm$core$Array$toIndexedList(pieces));
	var edgeSamples = $elm$core$List$filterMap$(
		function (edge) {
			return $elm$core$Maybe$map$(
				$elm$core$Tuple$pair(edge),
				samples(edge));
		},
		allEdges);
	var matchesFor = function (_v3) {
		var edge = _v3.a;
		var points = _v3.b;
		return $elm$core$List$map$(
			$elm$core$Tuple$first,
			$elm$core$List$filter$(
				function (_v2) {
					var otherEdge = _v2.a;
					var otherPoints = _v2.b;
					return (!_Utils_eq(otherEdge.a, edge.a)) && (A2(liesOn, otherEdge, points) && A2(liesOn, edge, otherPoints));
				},
				edgeSamples));
	};
	return $elm$core$List$foldl$(
		F2(
			function (edgeAndSamples, result) {
				var edge = edgeAndSamples.a;
				if (!result.$) {
					var seams = result.a;
					var _v1 = matchesFor(edgeAndSamples);
					if (_v1.b) {
						if (!_v1.b.b) {
							var other = _v1.a;
							return $elm$core$Result$Ok(
								$author$project$Surface$setSeam$(edge, other, seams));
						} else {
							return $elm$core$Result$Err(
								$author$project$Surface$EdgeSharedBy3OrMorePieces(
									describe(edge)));
						}
					} else {
						return $elm$core$Result$Err(
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
var $author$project$Surface$build$ = function (flatSpecs, featureSpecs) {
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
					return {u: pieces, aS: seams};
				},
				$author$project$Surface$findSeams(pieces));
		} else {
			var error = _v0.b.a;
			return $elm$core$Result$Err(error);
		}
	} else {
		var error = _v0.a.a;
		return $elm$core$Result$Err(error);
	}
};
var $author$project$Surface$build = F2($author$project$Surface$build$);
var $author$project$World$X = 0;
var $author$project$World$Y = 1;
var $author$project$World$Z = 2;
var $author$project$Surface$Circle = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$PartTurn = function (a) {
	return {$: 1, a: a};
};
var $ianmackenzie$elm_units$Angle$radians = function (numRadians) {
	return numRadians;
};
var $ianmackenzie$elm_units$Angle$degrees = function (numDegrees) {
	return $ianmackenzie$elm_units$Angle$radians($elm$core$Basics$pi * (numDegrees / 180));
};
var $author$project$World$filletRadius = 0.198579;
var $author$project$World$box = {
	aM: {i6: 4.236575, ja: 0.598373, i: 1.992144},
	aN: {i6: -3.343595, ja: -0.401627, i: -2.452917}
};
var $author$project$World$inner$ = function (axis, sign) {
	var get = function (v) {
		switch (axis) {
			case 0:
				return v.i6;
			case 1:
				return v.ja;
			default:
				return v.i;
		}
	};
	return (sign > 0) ? (get($author$project$World$box.aM) - $author$project$World$filletRadius) : (get($author$project$World$box.aN) + $author$project$World$filletRadius);
};
var $author$project$World$inner = F2($author$project$World$inner$);
var $ianmackenzie$elm_geometry$Geometry$Types$Point2d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Point2d$meters$ = function (x, y) {
	return {i6: x, ja: y};
};
var $ianmackenzie$elm_geometry$Point2d$meters = F2($ianmackenzie$elm_geometry$Point2d$meters$);
var $ianmackenzie$elm_geometry$Point2d$origin = {i6: 0, ja: 0};
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
				{i6: sign, ja: 0, i: 0});
		case 1:
			return $ianmackenzie$elm_geometry$Direction3d$unsafe(
				{i6: 0, ja: sign, i: 0});
		default:
			return $ianmackenzie$elm_geometry$Direction3d$unsafe(
				{i6: 0, ja: 0, i: sign});
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
		bG: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				dO: $author$project$World$point(
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
				eb: xDirection,
				ec: yDirection,
				fo: $author$project$World$unit$(1, signY)
			}),
		c5: {
			I: _List_fromArray(
				[
					$author$project$Surface$Circle(
					{
						cv: $ianmackenzie$elm_geometry$Point2d$origin,
						aH: $ianmackenzie$elm_geometry$Point2d$meters$(0, $author$project$World$filletRadius)
					})
				]),
			bQ: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$filletRadius, 0)
		},
		r: $author$project$Surface$PartTurn(
			{
				P: $ianmackenzie$elm_units$Angle$degrees(0),
				ab: $ianmackenzie$elm_units$Angle$degrees(90)
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
		bG: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				dO: $author$project$World$point(
					_List_fromArray(
						[
							_Utils_Tuple2(
							a,
							$author$project$World$inner$(a, signA)),
							_Utils_Tuple2(
							b,
							$author$project$World$inner$(b, signB))
						])),
				eb: $author$project$World$unit$(a, signA),
				ec: $author$project$World$unit$(b, signB),
				fo: $author$project$World$unit$(along, zSign)
			}),
		c5: {
			I: _List_fromArray(
				[
					$author$project$Surface$Line(
					{
						aH: $ianmackenzie$elm_geometry$Point2d$meters$(
							$author$project$World$filletRadius,
							zSign * $author$project$World$inner$(along, zSign))
					})
				]),
			bQ: $ianmackenzie$elm_geometry$Point2d$meters$(
				$author$project$World$filletRadius,
				zSign * $author$project$World$inner$(along, -zSign))
		},
		r: $author$project$Surface$PartTurn(
			{
				P: $ianmackenzie$elm_units$Angle$degrees(0),
				ab: $ianmackenzie$elm_units$Angle$degrees(90)
			})
	};
};
var $author$project$World$edgeFillet = F3($author$project$World$edgeFillet$);
var $author$project$Surface$FullTurn = {$: 0};
var $author$project$World$hole = {b5: 0.30432, d9: 0.47524, i6: 1.156, i: -0.2058};
var $author$project$World$holeRim = $author$project$World$hole.d9 + $author$project$World$hole.b5;
var $ianmackenzie$elm_geometry$Direction3d$negativeZ = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{i6: 0, ja: 0, i: -1});
var $ianmackenzie$elm_geometry$Direction3d$positiveX = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{i6: 1, ja: 0, i: 0});
var $ianmackenzie$elm_geometry$Direction3d$x = $ianmackenzie$elm_geometry$Direction3d$positiveX;
var $ianmackenzie$elm_geometry$Direction3d$positiveY = $ianmackenzie$elm_geometry$Direction3d$unsafe(
	{i6: 0, ja: 1, i: 0});
var $ianmackenzie$elm_geometry$Direction3d$y = $ianmackenzie$elm_geometry$Direction3d$positiveY;
var $author$project$World$holeFeature = function () {
	var top = $author$project$World$box.aM.ja;
	var bottom = $author$project$World$box.aN.ja;
	return {
		bG: $ianmackenzie$elm_geometry$Frame3d$unsafe(
			{
				dO: $ianmackenzie$elm_geometry$Point3d$meters$($author$project$World$hole.i6, 0, $author$project$World$hole.i),
				eb: $ianmackenzie$elm_geometry$Direction3d$x,
				ec: $ianmackenzie$elm_geometry$Direction3d$negativeZ,
				fo: $ianmackenzie$elm_geometry$Direction3d$y
			}),
		c5: {
			I: _List_fromArray(
				[
					$author$project$Surface$Circle(
					{
						cv: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, top - $author$project$World$hole.b5),
						aH: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.d9, top - $author$project$World$hole.b5)
					}),
					$author$project$Surface$Line(
					{
						aH: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.d9, bottom + $author$project$World$hole.b5)
					}),
					$author$project$Surface$Circle(
					{
						cv: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, bottom + $author$project$World$hole.b5),
						aH: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, bottom)
					})
				]),
			bQ: $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$holeRim, top)
		},
		r: $author$project$Surface$FullTurn
	};
}();
var $author$project$World$signs = _List_fromArray(
	[-1, 1]);
var $author$project$World$features = A2(
	$elm$core$List$cons,
	$author$project$World$holeFeature,
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
			$author$project$World$signs)));
var $author$project$Surface$Arc = function (a) {
	return {$: 1, a: a};
};
var $author$project$Surface$Straight = function (a) {
	return {$: 0, a: a};
};
var $ianmackenzie$elm_geometry$Geometry$Types$Vector2d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$Vector2d$meters$ = function (x, y) {
	return {i6: x, ja: y};
};
var $ianmackenzie$elm_geometry$Vector2d$meters = F2($ianmackenzie$elm_geometry$Vector2d$meters$);
var $author$project$World$outer$ = function (axis, sign) {
	return $author$project$World$inner$(axis, sign) + (sign * $author$project$World$filletRadius);
};
var $author$project$World$outer = F2($author$project$World$outer$);
var $ianmackenzie$elm_geometry$Point2d$translateBy$ = function (_v0, _v1) {
	var v = _v0;
	var p = _v1;
	return {i6: p.i6 + v.i6, ja: p.ja + v.ja};
};
var $ianmackenzie$elm_geometry$Point2d$translateBy = F2($ianmackenzie$elm_geometry$Point2d$translateBy$);
var $ianmackenzie$elm_geometry$Geometry$Types$SketchPlane3d = $elm$core$Basics$identity;
var $ianmackenzie$elm_geometry$SketchPlane3d$unsafe = $elm$core$Basics$identity;
var $author$project$World$boxFace$ = function (axis, sign) {
	var holeLoop = function () {
		if (axis === 1) {
			var center = (sign > 0) ? $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.i, $author$project$World$hole.i6) : $ianmackenzie$elm_geometry$Point2d$meters$($author$project$World$hole.i6, $author$project$World$hole.i);
			return _List_fromArray(
				[
					_List_fromArray(
					[
						$author$project$Surface$Arc(
						{
							cv: center,
							bQ: $ianmackenzie$elm_geometry$Point2d$translateBy$(
								$ianmackenzie$elm_geometry$Vector2d$meters$($author$project$World$holeRim, 0),
								center),
							e8: $ianmackenzie$elm_units$Angle$degrees(-360)
						})
					])
				]);
		} else {
			return _List_Nil;
		}
	}();
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
		dk: A2($elm$core$List$cons, rectangle, holeLoop),
		ck: $ianmackenzie$elm_geometry$SketchPlane3d$unsafe(
			{
				dO: $author$project$World$point(
					_List_fromArray(
						[
							_Utils_Tuple2(
							axis,
							$author$project$World$outer$(axis, sign))
						])),
				eb: $author$project$World$unit$(a, 1),
				ec: $author$project$World$unit$(b, 1)
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
var $author$project$World$surface = $author$project$Surface$build$($author$project$World$flats, $author$project$World$features);
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
var $author$project$MinimapWorker$minimapDrawn = _Platform_outgoingPort('minimapDrawn', $elm$core$Basics$identity);
var $author$project$Surface$SurfacePoint = $elm$core$Basics$identity;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $author$project$Surface$surfacePointDecoder = A5(
	$elm$json$Json$Decode$map4,
	F4(
		function (piece, a, b, heading) {
			return {cr: a, ct: b, e: heading, aa: piece};
		}),
	A2($elm$json$Json$Decode$field, 'piece', $elm$json$Json$Decode$int),
	A2($elm$json$Json$Decode$field, 'a', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'b', $elm$json$Json$Decode$float),
	A2($elm$json$Json$Decode$field, 'heading', $elm$json$Json$Decode$float));
var $author$project$MinimapWorker$update$ = function (_v0, _v1) {
	var value = _v0;
	var _v2 = _Utils_Tuple2(
		A2($elm$json$Json$Decode$decodeValue, $author$project$Surface$surfacePointDecoder, value),
		$author$project$MeshData$surface);
	if ((!_v2.a.$) && (!_v2.b.$)) {
		var point = _v2.a.a;
		var surface = _v2.b.a;
		return _Utils_Tuple2(
			0,
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
								$author$project$Minimap$drawingAround$(surface, $author$project$MeshData$mapShapes, point)))
						]))));
	} else {
		return _Utils_Tuple2(0, $elm$core$Platform$Cmd$none);
	}
};
var $author$project$MinimapWorker$update = F2($author$project$MinimapWorker$update$);
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$MinimapWorker$main = $elm$core$Platform$worker(
	{
		hJ: function (_v0) {
			return _Utils_Tuple2(0, $elm$core$Platform$Cmd$none);
		},
		iI: function (_v1) {
			return $author$project$MinimapWorker$drawMinimap($elm$core$Basics$identity);
		},
		i2: $author$project$MinimapWorker$update
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

