import std.stdio;
import std.file;
import std.string;
import std.array;
import std.algorithm;
import std.typecons : tuple, Tuple;
import std.math.rounding;
import std.conv;

// Read the input grid from file
auto readfile(string path)
{
	auto file = File(path, "r");
	return file.byLine()
		.map!(line => line.strip().splitter(" ")
				.map!(c => c.idup).array)
		.array;
}

void main()
{
	string[][] value = readfile("test.txt");

	auto gcd(int x, int y)
	{
		int v;
		while (y != 0)
		{
			int temp = y;
			y = x % y;
			x = temp;
			v = x;
		}

		return v;
	}

	auto extended_eu(int A, int B)
	{
		if (B == 0)
		{
			return tuple(1, 0); // Base case: gcd(A, 0) = A, so x = 1, y = 0
		}
		auto vv = extended_eu(B, A % B); // Recursive call
		int x1 = vv[0];
		int y1 = vv[1];

		int x = y1;
		int y = x1 - (A / B) * y1; // Ensure correct integer division

		return tuple(x, y);
	}

	auto solver(int Ax, int Ay, int Bx, int By, int Px, int Py)
	{
		// Compute GCDs
		auto gcd_x = gcd(Ax, Bx);
		auto gcd_y = gcd(Ay, By);

		// Check if a solution exists (Px and Py must be divisible by gcd_x and gcd_y)
		if (Px % gcd_x != 0 || Py % gcd_y != 0)
		{
			return -1; // No solution exists
		}

		// Find particular solutions using Extended Euclidean Algorithm
		auto v = extended_eu(Ax, Bx);
		auto v1 = extended_eu(Ay, By);
		int x0 = v[0]; // Solution for X direction
		int y0 = v[1];
		int a0 = v1[0]; // Solution for Y direction
		int b0 = v1[1];

		// Scale solutions to match Px and Py
		x0 *= (Px / gcd_x);
		y0 *= (Py / gcd_y);
		a0 *= (Py / gcd_y);
		b0 *= (Px / gcd_x);

		// Find the range of k for non-negative solutions
		int k_min_x = cast(int) ceil(cast(real)(-x0) / (Bx / gcd_x));
		int k_min_y = cast(int) ceil(cast(real)(-a0) / (By / gcd_y));
		int k_min = max(k_min_x, k_min_y);

		int k_max_x = cast(int) floor(cast(real)(Px - x0) / (Bx / gcd_x));
		int k_max_y = cast(int) floor(cast(real)(Py - a0) / (By / gcd_y));
		int k_max = min(k_max_x, k_max_y);

		// Check if there is a valid range for k
		if (k_min > k_max)
		{
			return -1; // No valid non-negative solution exists
		}

		// Find the optimal k that minimizes the total cost
		int bestCost = int.max;
		for (int k = k_min; k <= k_max; ++k)
		{
			int a = x0 + k * (Bx / gcd_x);
			int b = a0 + k * (By / gcd_y);
			int cost = a * 3 + b * 1;

			if (cost < bestCost)
			{
				bestCost = cost;
			}
		}

		return bestCost;
	}

	int i = 0;

	while (i < value.length)
	{
		auto buttonAData = value[i];
		int Ax = buttonAData[2][2 .. $ - 1].to!int; // Remove "X+" prefix and trailing comma
		int Ay = buttonAData[3][2 .. $].to!int; // Remove "Y+" prefix

		// Parse Button B data
		auto buttonBData = value[i + 1];
		int Bx = buttonBData[2][2 .. $ - 1].to!int; // Remove "X+" prefix and trailing comma
		int By = buttonBData[3][2 .. $].to!int; // Remove "Y+" prefix

		// Parse Prize data
		auto prizeData = value[i + 2];
		int Px = prizeData[1][2 .. $ - 1].to!int; // Remove "X=" prefix and trailing comma
		int Py = prizeData[2][2 .. $].to!int; // Remove "Y=" prefix

		// Call the solver function for this claw machine
		writeln(Ax);
		writeln(Ay);
		writeln(Bx);
		writeln(By);
		writeln(Px);
		writeln(Py);
		int result = solver(Ax, Ay, Bx, By, Px, Py);
		{
			writeln("Minimum cost to win the prize: ", result);
		}

		// Move to the next set of inputs
		i += 4;
	}
}
