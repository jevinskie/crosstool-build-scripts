%rename libgcc old_libgcc

*libgcc:
    %{!static:%{!static-libgcc:%{!static-pie:%{!shared-libgcc:-rpath %:canonical_path_no_resolve_symlinks(%:join(%:dirname(%:getenv(COLLECT_GCC %")) /../lib%{m32:32}%{!m32:64}))}%{shared-libgcc:-rpath %:canonical_path_no_resolve_symlinks(%:join(%:dirname(%:getenv(COLLECT_GCC %")) /../lib%{m32:32}%{!m32:64}))}}}} %(old_libgcc)
