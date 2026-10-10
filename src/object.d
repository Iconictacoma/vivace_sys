module object;

alias size_t = uint;
alias ptrdiff_t = int;

class Object {}
class Throwable {}
class Error : Throwable {}
class Exception : Throwable {}

struct TypeInfo {}