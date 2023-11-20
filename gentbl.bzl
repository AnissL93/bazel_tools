load("@llvm-project//mlir:tblgen.bzl", "gentbl_cc_library", "td_library")
load("@llvm-project//llvm:lit_test.bzl", "lit_test")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

def lit_testsuite(name, data = []):
    [
        lit_test(
            name = "%s.test" % src,
            srcs = [src],
            data = [
                "//mlir:mlir-opt",
                "//mlir/test:lit_data",
                "//cc/tools:pagoda-compiler",
            ] + data,
        )
        for src in ["ops.mlir"]
    ]

def gentbl_dialect(name, td_file, deps = []):
    """
    Generate dialect, op defination, enum,
    """

    def replace_ext(f, ext):
        return f.split(".")[0] + "." + ext

    gentbl_cc_library(
        name = name,
        tbl_outs = [
            # generate dialect
            (
                [
                    "--gen-dialect-decls",
                ],
                replace_ext(td_file, "dialect.h.inc"),
            ),
            (
                [
                    "--gen-dialect-defs",
                ],
                replace_ext(td_file, "dialect.cc.inc"),
            ),
            (
                ["-gen-op-decls"],
                replace_ext(td_file, "op.h.inc"),
            ),
            (
                ["-gen-op-defs"],
                replace_ext(td_file, "op.cc.inc"),
            ),
        ],
        tblgen = "@llvm-project//mlir:mlir-tblgen",
        td_file = td_file,
        deps = [
            "@llvm-project//mlir:OpBaseTdFiles",
            "@llvm-project//mlir:SideEffectInterfacesTdFiles",
        ] + deps,
    )
