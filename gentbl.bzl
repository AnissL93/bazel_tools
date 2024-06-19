load("@llvm-project//mlir:tblgen.bzl", "gentbl_cc_library", "td_library")
load("@llvm-project//llvm:lit_test.bzl", "lit_test")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

def replace_ext(f, ext):
    return f.split(".")[0] + "." + ext

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

def gentbl_interface(
        name,
        td_file,
        deps = []):
    """
    Generate interface
    """

    out_header = replace_ext(td_file, "interf.h.inc")
    out_src = replace_ext(td_file, "interf.cc.inc")
    gentbl_cc_library(
        name = name,
        tbl_outs = [
            (
                ["-gen-op-interface-decls"],
                out_header,
            ),
            (
                ["-gen-op-interface-defs"],
                out_src,
            ),
        ],
        tblgen = "@llvm-project//mlir:mlir-tblgen",
        td_file = td_file,
        deps = [
            "@llvm-project//mlir:BuiltinDialectTdFiles",
            "@llvm-project//mlir:OpBaseTdFiles",
            "@llvm-project//mlir:SideEffectInterfacesTdFiles",
        ] + deps,
    )

def gentbl_dialect(
        name,
        td_file,
        deps = [],
        dialect_name = None,
        gen_type = False,
        gen_attr = False):
    """
    Generate dialect, op defination, enum,
    """

    if gen_attr:
        attr_gen = [
            (
                [
                    "--gen-attrdef-defs",
                    "--attrdefs-dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "attr.cc.inc"),
            ),
            (
                [
                    "--gen-attrdef-decls",
                    "--attrdefs-dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "attr.h.inc"),
            ),
        ]
    else:
        attr_gen = []

    if gen_type:
        type_gen = [
            (
                [
                    "--gen-typedef-defs",
                    "--typedefs-dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "type.cc.inc"),
            ),
            (
                [
                    "--gen-typedef-decls",
                    "--typedefs-dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "type.h.inc"),
            ),
        ]
    else:
        type_gen = []

    gentbl_cc_library(
        name = name,
        tbl_outs = [
            # generate dialect
            (
                [
                    "--gen-dialect-decls",
                    "--dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "dialect.h.inc"),
            ),
            (
                [
                    "--gen-dialect-defs",
                    "--dialect={}".format(dialect_name),
                ],
                replace_ext(td_file, "dialect.cc.inc"),
            ),
            (
                ["--gen-op-decls"],
                replace_ext(td_file, "op.h.inc"),
            ),
            (
                ["--gen-op-defs"],
                replace_ext(td_file, "op.cc.inc"),
            ),
        ] + type_gen + attr_gen,
        tblgen = "@llvm-project//mlir:mlir-tblgen",
        td_file = td_file,
        deps = [
            "@llvm-project//mlir:BuiltinDialectTdFiles",
            "@llvm-project//mlir:OpBaseTdFiles",
            "@llvm-project//mlir:SideEffectInterfacesTdFiles",
        ] + deps,
    )

def gentbl_pass(name, td_file, dialect_name, deps = []):
    inc_file = replace_ext(td_file, "h.inc")
    gentbl_cc_library(
        name = name,
        tbl_outs = [
            (
                [
                    "-gen-pass-decls",
                    "-name={}".format(dialect_name),
                ],
                inc_file,
            ),
        ],
        tblgen = "@llvm-project//mlir:mlir-tblgen",
        td_file = td_file,
        deps = ["@llvm-project//mlir:PassBaseTdFiles"] + deps,
    )
