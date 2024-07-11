%rename lib old_lib

*lib:
    %(old_lib) %:notice(old_lib: %(old_lib)) %:notice(\%D: %D) %:notice(sanitize: %{%:sanitize():got_sanitize}) %:notice(sanitize(address): %{%:sanitize(address):got_sanitize_address})

%rename libgcc old_libgcc

*libgcc:
    %(old_libgcc) %s %:notice(old_libgcc: %(old_libgcc))

%rename link_gcc_c_sequence old_link_gcc_c_sequence

*link_gcc_c_sequence:
    %(old_link_gcc_c_sequence) %:notice(old_link_gcc_c_sequence: %(old_link_gcc_c_sequence))

%rename link_ssp old_link_ssp

*link_ssp:
    %(old_link_ssp) %:notice(old_link_ssp: %(old_link_ssp))

#%rename link_libasan old_link_libasan

#*link_libasan:
#    %(old_link_libasan) %:notice(old_link_libasan: %(old_link_libasan))
