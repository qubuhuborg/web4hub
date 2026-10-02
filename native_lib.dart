import 'dart:ffi';
import 'dart:io';

typedef AddFunc = Int32 Function(Int32 a, Int32 b);
typedef Add = int Function(int a, int b);

final DynamicLibrary nativeLib = Platform.isAndroid || Platform.isLinux
    ? DynamicLibrary.open('libnative_lib.so')
    : Platform.isWindows
        ? DynamicLibrary.open('native_lib.dll')
        : DynamicLibrary.process();

final Add add = nativeLib
    .lookup<NativeFunction<AddFunc>>('add')
    .asFunction();
