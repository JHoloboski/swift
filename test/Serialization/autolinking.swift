// RUN: rm -rf %t
// RUN: mkdir %t
// RUN: %target-swift-frontend -emit-module -parse-stdlib -o %t -module-name someModule -module-link-name module %S/../Inputs/empty.swift
// RUN: %target-swift-frontend -emit-ir -lmagic %s -I %t > %t/out.txt
// RUN: FileCheck %s < %t/out.txt
// RUN: FileCheck -check-prefix=NO-FORCE-LOAD %s < %t/out.txt

// RUN: mkdir -p %t/someModule.framework/Modules/someModule.swiftmodule/
// RUN: mv %t/someModule.swiftmodule %t/someModule.framework/Modules/someModule.swiftmodule/%target-swiftmodule-name
// RUN: %target-swift-frontend -emit-ir -lmagic %s -F %t > %t/framework.txt
// RUN: FileCheck -check-prefix=FRAMEWORK %s < %t/framework.txt
// RUN: FileCheck -check-prefix=NO-FORCE-LOAD %s < %t/framework.txt

// RUN: %target-swift-frontend -emit-module -parse-stdlib -o %t -module-name someModule -module-link-name module %S/../Inputs/empty.swift -autolink-force-load
// RUN: %target-swift-frontend -emit-ir -lmagic %s -I %t > %t/force-load.txt
// RUN: FileCheck %s < %t/force-load.txt
// RUN: FileCheck -check-prefix=FORCE-LOAD-CLIENT %s < %t/force-load.txt

// RUN: %target-swift-frontend -emit-ir -parse-stdlib -module-name someModule -module-link-name module %S/../Inputs/empty.swift | FileCheck --check-prefix=NO-FORCE-LOAD %s
// RUN: %target-swift-frontend -emit-ir -parse-stdlib -module-name someModule -module-link-name module %S/../Inputs/empty.swift -autolink-force-load | FileCheck --check-prefix=FORCE-LOAD %s
// RUN: %target-swift-frontend -emit-ir -parse-stdlib -module-name someModule -module-link-name 0module %S/../Inputs/empty.swift -autolink-force-load | FileCheck --check-prefix=FORCE-LOAD-HEX %s

// UNSUPPORTED: OS=linux-gnu

import someModule

// CHECK: !{{[0-9]+}} = !{i32 6, !"Linker Options", ![[LINK_LIST:[0-9]+]]}
// CHECK: ![[LINK_LIST]] = !{
// CHECK-DAG: !{{[0-9]+}} = !{!"-lmagic"}
// CHECK-DAG: !{{[0-9]+}} = !{!"-lmodule"}

// FRAMEWORK: !{{[0-9]+}} = !{i32 6, !"Linker Options", ![[LINK_LIST:[0-9]+]]}
// FRAMEWORK: ![[LINK_LIST]] = !{
// FRAMEWORK-DAG: !{{[0-9]+}} = !{!"-lmagic"}
// FRAMEWORK-DAG: !{{[0-9]+}} = !{!"-lmodule"}
// FRAMEWORK-DAG: !{{[0-9]+}} = !{!"-framework", !"someModule"}

// NO-FORCE-LOAD-NOT: FORCE_LOAD
// FORCE-LOAD: @"_swift_FORCE_LOAD_$_module" = common global i1 false
// FORCE-LOAD-HEX: @"_swift_FORCE_LOAD_$306d6f64756c65" = common global i1 false

// FORCE-LOAD-CLIENT: @"_swift_FORCE_LOAD_$_module" = external global i1
// FORCE-LOAD-CLIENT: @"_swift_FORCE_LOAD_$_module_$_autolinking" = weak hidden constant i1* @"_swift_FORCE_LOAD_$_module"

// FORCE-LOAD-CLIENT: @llvm.used = appending global [{{[0-9]+}} x i8*] [
// FORCE-LOAD-CLIENT: i8* bitcast (i1** @"_swift_FORCE_LOAD_$_module_$_autolinking" to i8*)
// FORCE-LOAD-CLIENT: ], section "llvm.metadata"
