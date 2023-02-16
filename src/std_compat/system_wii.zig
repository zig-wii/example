const c = @import("c.zig");

//Import libc items

pub const dl_phdr_info = void;

// From stdlib.h
pub const exit = c.exit;
pub const getenv = c.getenv;

// From unistd.h
pub const fd_t = c_int;
pub const STDOUT_FILENO = c.STDOUT_FILENO;
pub const STDERR_FILENO = c.STDERR_FILENO;
pub const write = c.write;
pub const isatty = c.isatty;

// From ogc/mutex.h
pub const pthread_mutex_t = extern struct {
    inner: ?*anyopaque = null,
};
pub const pthread_cond_t = extern struct {
    inner: ?*anyopaque = null,
};
// TODO: replace all pthread/mutex/semaphore stuff with LWP functions
pub const PTHREAD_MUTEX_INITIALIZER = c.LWP_MutexInit;
pub const pthread_mutex_lock = c.LWP_MutexLock;

// From time.h
pub const timespec = c.timespec;
pub const clockid_t = i32;
pub fn clock_gettime(clock_id: clockid_t, tp: [*c]timespec) c_int {
    return c.clock_gettime(@bitCast(c.clockid_t, clock_id), tp);
}
pub const CLOCK = .{
    .REALTIME = 1
};

// From errno.h
pub const E = enum(c_int) {
    SUCCESS = 0,
    PERM = 1,
    NOENT = 2,
    SRCH = 3,
    INTR = 4,
    IO = 5,
    NXIO = 6,
    @"2BIG" = 7,
    NOEXEC = 8,
    BADF = 9,
    CHILD = 10,
    // WOULDBLOCK = 11,
    AGAIN = 11,
    NOMEM = 12,
    ACCES = 13,
    FAULT = 14,
    BUSY = 16,
    EXIST = 17,
    XDEV = 18,
    NODEV = 19,
    NOTDIR = 20,
    ISDIR = 21,
    INVAL = 22,
    NFILE = 23,
    MFILE = 24,
    NOTTY = 25,
    TXTBSY = 26,
    FBIG = 27,
    NOSPC = 28,
    SPIPE = 29,
    ROFS = 30,
    MLINK = 31,
    PIPE = 32,
    DOM = 33,
    RANGE = 34,
    NOMSG = 35,
    IDRM = 36,
    DEADLK = 45,
    NOLCK = 46,
    NOSTR = 60,
    NODATA = 61,
    TIME = 62,
    NOSR = 63,
    NOLINK = 67,
    PROTO = 71,
    MULTIHOP = 74,
    BADMSG = 77,
    FTYPE = 79,
    NOSYS = 88,
    NOTEMPTY = 90,
    NAMETOOLONG = 91,
    LOOP = 92,
    OPNOTSUPP = 95,
    PFNOSUPPORT = 96,
    CONNRESET = 104,
    NOBUFS = 105,
    AFNOSUPPORT = 106,
    PROTOTYPE = 107,
    NOTSOCK = 108,
    NOPROTOOPT = 109,
    CONNREFUSED = 111,
    ADDRINUSE = 112,
    CONNABORTED = 113,
    NETUNREACH = 114,
    NETDOWN = 115,
    TIMEDOUT = 116,
    HOSTDOWN = 117,
    HOSTUNREACH = 118,
    INPROGRESS = 119,
    ALREADY = 120,
    DESTADDRREQ = 121,
    MSGSIZE = 122,
    PROTONOSUPPORT = 123,
    ADDRNOTAVAIL = 125,
    NETRESET = 126,
    ISCONN = 127,
    NOTCONN = 128,
    TOOMANYREFS = 129,
    DQUOT = 132,
    STALE = 133,
    NOTSUP = 134,
    ILSEQ = 138,
    OVERFLOW = 139,
    CANCELED = 140,
    NOTRECOVERABLE = 141,
    OWNERDEAD = 142,
};
pub fn getErrno(rc: anytype) E {
    if (rc == -1) {
        return @intToEnum(E, c.__errno().*);
    } else {
        return .SUCCESS;
    }
}