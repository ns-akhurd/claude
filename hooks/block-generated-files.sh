#!/bin/bash
# Hook: block writes to auto-generated files.
# These files are produced by flatc, protoc, featurec, VPP API gen — never edit directly.
f=$(python3 -c "import json,os; print(json.loads(os.environ.get('CLAUDE_TOOL_INPUT','{}')).get('file_path',''))" 2>/dev/null)
[ -z "$f" ] && exit 0

for pat in _generated.h .pb.h .pb.cc .grpc.pb.h .grpc.pb.cc .fc.hpp .fc.cpp .api.h .api.c; do
    if [[ "$f" == *"$pat" ]]; then
        echo "BLOCKED: '$f' is auto-generated." >&2
        echo "Edit the source file instead:" >&2
        echo "  .fbs  -> flatc generates *_generated.h" >&2
        echo "  .proto -> protoc generates .pb.h/.pb.cc/.grpc.pb.*" >&2
        echo "  .featurec -> featurec generates .fc.hpp/.fc.cpp" >&2
        echo "  .api.template -> VPP gen produces .api.h/.api.c" >&2
        exit 1
    fi
done
exit 0
