#%rename cpp old_cpp

#*cpp:
#	%(old_cpp)

%rename link old_link

*link:
	%(old_link) %{static:im-a-static}

