`timescale 1ns / 100ps

module comparator (

    input  [30:0] A,
    input  [30:0] B,
    output comp,
    output magcheck,
    output zero,
    output [7:0] BigExp,
    output [7:0] SmallExp,
    output [23:0] BigMan,
    output [23:0] SmallMan
);

    assign comp = (A[30:23] > B[30:23]) ? 1'b1 : 1'b0;
    assign magcheck = (A[30:23] ~^ B[30:23]) ? ((A[22:0] > B[22:0]) ? 1'b1 : 1'b0):1'b0;
    assign zero = (A == 0 && B == 0);

    assign BigExp = zero ? 'b0 : comp ? A[30:23] : B[30:23];
    assign SmallExp = zero ? 'b0 : comp ? B[30:23] : A[30:23];

    assign BigMan = zero ? 'b0 : (comp | magcheck) ? {1'b1, A[22:0]} : {1'b1, B[22:0]};
    assign SmallMan = zero ? 'b0 : (comp | magcheck) ? {1'b1, B[22:0]} : {1'b1, A[22:0]};

endmodule
