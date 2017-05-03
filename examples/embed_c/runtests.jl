import Base.Test

cwd = pwd()
workdir = joinpath(Mads.madsdir, "..", "examples", "embed_c")
cd(workdir)

mylib = ""
if is_apple()
	mylib = "libmy.dylib"
elseif is_linux()
	mylib = "libmy.so"
end

if mylib == ""
	warn("embed_c test is skipped")
else
	# Build the C library if it doesn't exist
	if isfile(joinpath(workdir, mylib)) != true
		run(`make`)
	end

	# Test Julia's sqrt against C's sqrt in <math.h>
	function test_sqrt(d)
		fcsqrt(d) = ccall( (:my_c_sqrt, mylib), Float64, (Float64,), d )

		@Base.Test.test fcsqrt(d) ≈ sqrt(d)
	end

	# Test an equivalent summation equation
	function test_ex1(n, d)
		fcfunc_ex1(n, d) = ccall( (:my_c_func_ex1, mylib), Float64, (Int64, Float64), n, d )

		r = 0
		for i = 1:n
			r += i / d
		end

		@Base.Test.test fcfunc_ex1(n,d) ≈ r
	end

	# Run the tests
	@Base.Test.testset "Calling C" begin
		if isfile(joinpath(workdir, mylib))
			test_sqrt(2)
			test_ex1(100, 6.4)
		else
			println("C library doesn't exist! Navigate to this directory and `make`")
		end
	end
end

cd(cwd)