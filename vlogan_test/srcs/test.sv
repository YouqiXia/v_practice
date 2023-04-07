import "DPI-C" function int factorial(int n);

module top;
    initial begin
        int n = 5;
        int result = factorial(n);
        $display("The factorial of %0d is %0d", n, result);
    end
endmodule
