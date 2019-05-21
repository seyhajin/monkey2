
Namespace mx2

#Import "util"

#Import "scope"
#Import "value"
#Import "type"
#Import "node"
#Import "stmt"
#Import "filescope"
#Import "block"

#Import "errors"
#Import "toker"
#Import "parser"
#Import "decl"
#Import "expr"
#Import "eval"
#Import "stmtexpr"
#Import "class"
#Import "func"
#Import "var"
#Import "enum"
#Import "property"
#Import "alias"
#Import "namespace"
#Import "overload"
#Import "balance"
#Import "module"
#Import "nodefinder"

#Import "translator"
#Import "translator_cpp"
#Import "mung"

#Import "builder"
#Import "buildproduct"

Using std
Using std.stringio
Using std.filesystem
Using std.collections
Using libc

'Make sure to rebuildall after changing this!
Const MX2CC_VERSION:="1.1.15"

'For 'emergency patch' versions, 'b', 'c' etc...
Const MX2CC_VERSION_EXT:="d"


