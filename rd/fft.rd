=begin
= Fast Fourier Transforms
Contents:
(1) ((<Mathematical Definitions|URL:fft.html#1>))
(2) ((<Complex data FFTs|URL:fft.html#2>))
    (1) ((<Overview of complex data FFTs|URL:fft.html#2.1>))
    (2) ((<Radix-2 FFT routines for complex data|URL:fft.html#2.2>))
        (1) ((<Example of the complex Radix-2 FFT|URL:fft.html#2.2.1>))
    (3) ((<Mixed-radix FFT routines for complex data|URL:fft.html#2.3>))
        (1) ((<GSL::FFT::ComplexWavetable class|URL:fft.html#2.3.1>))
        (2) ((<GSL::FFT::ComplexWorkspace class|URL:fft.html#2.3.2>))
        (3) ((<Methods to compute the transform|URL:fft.html#2.3.3>))
        (4) ((<Example of the mixed-radix FFT|URL:fft.html#2.3.4>))
(3) ((<Real data FFTs|URL:fft.html#3>))
    (1) ((<Overview of real data FFTs|URL:fft.html#3.1>))
    (2) ((<Radix-2 FFT routines for real data|URL:fft.html#3.2>))
    (3) ((<Mixed-radix FFT routines for real data|URL:fft.html#3.3>))
        (1) ((<Data storage scheme|URL:fft.html#3.3.1>))
        (2) ((<Wavetable and Workspace classes|URL:fft.html#3.3.2>))
        (3) ((<Methods for real FFTs|URL:fft.html#3.3.3>))
        (4) ((<Examples|URL:fft.html#3.3.4>))

== Mathematical Definitions 
Fast Fourier Transforms are efficient algorithms for calculating the discrete 
fourier transform (DFT), 

The DFT usually arises as an approximation to the continuous fourier transform 
when functions are sampled at discrete intervals in space or time. 
The naive evaluation of the discrete fourier transform is a matrix-vector 
multiplication W\vec{z}. A general matrix-vector multiplication takes O(N^2) 
operations for N data-points. Fast fourier transform algorithms use a 
divide-and-conquer strategy to factorize the matrix W into smaller 
sub-matrices, corresponding to the integer factors of the length N. 
If N can be factorized into a product of integers f_1 f_2 ... f_n then the 
DFT can be computed in O(N \sum f_i) operations. For a radix-2 FFT this 
gives an operation count of O(N \log_2 N). 

All the FFT functions offer three types of transform: forwards, inverse and
backwards, based on the same mathematical definitions. The definition of the 
forward fourier transform, x = FFT(z), is, and the definition of the inverse 
fourier transform, x = IFFT(z), is, The factor of 1/N makes this a true 
inverse. For example, a call to gsl_fft_complex_forward followed by a call 
to gsl_fft_complex_inverse should return the original data (within numerical 
errors). 

In general there are two possible choices for the sign of the exponential 
in the transform/ inverse-transform pair. GSL follows the same convention as
FFTPACK, using a negative exponential for the forward transform. 
The advantage of this convention is that the inverse transform recreates 
the original function with simple fourier synthesis. Numerical Recipes uses 
the opposite convention, a positive exponential in the forward transform. 

The backwards FFT is simply our terminology for an unscaled version of the 
inverse FFT, When the overall scale of the result is unimportant it is often 
convenient to use the backwards FFT instead of the inverse to save unnecessary
divisions. 


== Complex data FFTs
=== Overview of complex data FFTs
The complex data FFT routines are provided as instance methods of
((<GSL::Vector::Complex|URL:vector_complex.html>)).

Here is a table which shows the layout of the array data, and the correspondence 
between the time-domain complex data z, and the frequency-domain complex data x.

        index    z               x = FFT(z)

        0        z(t = 0)        x(f = 0)
        1        z(t = 1)        x(f = 1/(N Delta))
        2        z(t = 2)        x(f = 2/(N Delta))
        .        ........        ..................
        N/2      z(t = N/2)      x(f = +1/(2 Delta),
                                       -1/(2 Delta))
        .        ........        ..................
        N-3      z(t = N-3)      x(f = -3/(N Delta))
        N-2      z(t = N-2)      x(f = -2/(N Delta))
        N-1      z(t = N-1)      x(f = -1/(N Delta))


When N is even the location N/2 contains the most positive and negative
frequencies +1/(2 Delta), -1/(2 Delta) which are equivalent. If N is odd then
general structure of the table above still applies, but N/2 does not appear.

=== Radix-2 FFT routines for complex data
The radix-2 algorithms are simple and compact, although not necessarily the 
most efficient. They use the Cooley-Tukey algorithm to compute complex 
FFTs for lengths which are a power of 2 -- no additional storage is required. 
The corresponding self-sorting mixed-radix routines offer better performance 
at the expense of requiring additional working space.

((*The FFT methods described below return FFTed data, and the input vector is 
not changed. Use methods with '!' as (({tranform!})) for in-place transform.*))

--- GSL::Vector::Complex#radix2_forward
--- GSL::Vector::Complex#radix2_backward
--- GSL::Vector::Complex#radix2_inverse

    These functions compute forward, backward and inverse FFTs of the complex
    vector using a radix-2 decimation-in-time algorithm.  The length of the
    transform is restricted to powers of two.  These methods return the FFTed
    data, and the input data is not changed.

--- GSL::Vector::Complex#radix2_transform(sign)

    The sign argument can be either (({GSL::FFT::FORWARD})) or (({GSL::FFT::BACKWARD})).
    
--- GSL::Vector::Complex#radix2_dif_forward
--- GSL::Vector::Complex#radix2_dif_backward
--- GSL::Vector::Complex#radix2_dif_inverse
--- GSL::Vector::Complex#radix2_dif_transform

    These are decimation-in-frequency versions of the radix-2 FFT functions.

==== Example of complex Radix-2 FFT
Here is an example program which computes the FFT of a short pulse in a 
sample of length  128. To make the resulting Fourier transform real the pulse 
is defined for equal positive and negative times (-10 ... 10), where the 
negative times wrap around the end of the array.

        require("gsl")
        include GSL

        n = 128
        data = Vector::Complex[n]

        data[0] = 1.0
        for i in 1..10 do
          data[i] = 1.0
          data[n-i] = 1.0
        end

        #for i in 0...n do
        #  printf("%d %e %e\n", i, data[i].re, data[i].im)
        #end

        # You can choose whichever you like
        #ffted = data.radix2_forward()
        ffted = data.radix2_transform(FFT::FORWARD)
        ffted /= Math::sqrt(n)
        for i in 0...n do
          printf("%d %e %e\n", i, ffted[i].re, ffted[i].im)
        end

=== Mixed-radix FFT routines for complex data

==== GSL::FFT::ComplexWavetable class
--- GSL::FFT::ComplexWavetable.alloc(n)

    This method prepares a trigonometric lookup table for a complex FFT of length ((|n|)).
    The length ((|n|)) is factorized into a product of subtransforms, and the factors and their 
    trigonometric coefficients are stored in the wavetable. The trigonometric coefficients are 
    computed using direct calls to sin and cos, for accuracy. Recursion relations could be used 
    to compute the lookup table faster, but if an application performs many FFTs of the same 
    length then this computation is a one-off overhead which does not affect the final 
    throughput.

    The (({Wavetable})) object can be used repeatedly for any transform of the same length.
    The table is not modified by calls to any of the other FFT functions. The same wavetable 
    can be used for both forward and backward (or inverse) transforms of a given length.

--- GSL::FFT::ComplexWavetable#n
--- GSL::FFT::ComplexWavetable#nf
--- GSL::FFT::ComplexWavetable#factor

==== GSL::FFT::ComplexWorkspace class
--- GSL::FFT::ComplexWorkspace.alloc(n)

    Creates a workspace for a complex transform of length ((|n|)).

==== Methods to compute transform
((*The FFT methods described below return FFTed data, and the input vector is not changed. Use methods with '!' as (({tranform!})) for in-place transform.*))

--- GSL::Vector::Complex#forward(table, work)
--- GSL::Vector::Complex#forward(table)
--- GSL::Vector::Complex#forward(work)
--- GSL::Vector::Complex#forward()
--- GSL::Vector::Complex#backward(arguments same as forward)
--- GSL::Vector::Complex#inverse(arguments same as forward)
--- GSL::Vector::Complex#transform(arguments same as forward, sign)

    These methods compute forward, backward and inverse FFTs of the complex
    vector ((|self|)), using a mixed radix decimation-in-frequency algorithm.
    There is no restriction on the length.  Efficient modules are provided for
    subtransforms of length 2, 3, 4, 5, 6 and 7.  Any remaining factors are
    computed with a slow, O(n^2), general-n module.
    
    The caller can supply a ((|table|)) containing the trigonometric lookup
    tables and a workspace ((|work|)) (they are optional).
    
    The sign argument for the method (({transform})) can be either
    (({GSL::FFT::FORWARD})) or (({GSL::FFT::BACKWARD})).

    These methods return the FFTed data, and the input data is not changed.

#    These methods return a value.
#    * (({GSL::SUCCESS})): if no errors were detected.
#    * (({GSL::EDOM})): the length of the data ((|n|)) is not a positive integer (i.e. ((|n|)) is zero),
#    * (({GSL::EINVAL})): the length of the data ((|n|)) and the length used to compute the given wavetable do not match.

==== Example to use the mixed-radix FFT algorithm
      require 'gsl'
      include GSL

      n = 630
      data = FFT::Vector::Complex[n]

      table = FFT::ComplexWavetable.alloc(n)
      space = FFT::ComplexWorkspace.alloc(n)

      data[0] = 1.0
      for i in 1..10 do
        data[i] = 1.0
      end

      ffted = data.forward(table, space)
      #ffted = data.forward()
      #ffted = data.transform(FFT:Forward)

      ffted /= Math::sqrt(n)
      for i in 0...n do
        printf("%d %e %e\n", i, data[i].re, data[i].im)
      end

== Real data FFTs
=== Overview of real data FFTs 

The functions for real data FFTs are provided as instance methods of
((<GSL::Vector|URL:vector.class>)).  While they are similar to those for
complex data, there is an important difference in the data storage layout
between forward and inverse transforms.  The Fourier transform of a real
sequence is not real. It is a complex sequence with a special symmetry.  A
sequence with this symmetry is called ((|conjugate-complex|)) or
((|half-complex|)) and requires only as much storage as the original real
sequence instead of twice as much.

Forward transforms of real sequences produce half complex sequences of the same
length.  Backward and inverse transforms of half complex sequences produce real
sequences of the same length.  In both cases, the input and output sequences
are instances of ((<GSL::Vector|URL:vector.html>)).

The precise storage arrangements of half complex seqeunces depend on the
algorithm, and are different for radix-2 and mixed-radix routines. The radix-2
functions operate in-place, which constrains the locations where each element
can be stored. The restriction forces real and imaginary parts to be stored far
apart.  The mixed-radix algorithm does not have this restriction, and it stores
the real and imaginary parts of a given term in neighboring locations (which is
desirable for better locality of memory accesses).  This means that a half
complex sequence produces by a radix-2 forward transform ((*cannot*)) be
recovered by a mixed-radix inverse transform (and vice versa).

=== Radix-2 FFT routines for real data
The routines for readix-2 real FFTs are provided as instance methods of
((<GSL::Vector|URL:vector.html>)).

((*The FFT methods described below return FFTed data, and the input vector is
not changed. Use methods with '!' as (({radix2_tranform!})) for in-place
transform.*))

--- GSL::Vector#real_radix2_transform
--- GSL::Vector#radix2_transform
--- GSL::Vector#real_radix2_forward
--- GSL::Vector#radix2_forward

    These methods compute a radix-2 FFT of the real vector ((|self|)).  The
    output is a half-complex sequence.  The arrangement of the half-complex
    terms uses the following scheme: for k < N/2 the real part of the k-th term
    is stored in location k, and the corresponding imaginary part is stored in
    location N-k. Terms with k > N/2 can be reconstructed using the symmetry
    z_k = z^*_{N-k}. The terms for k=0 and k=N/2 are both purely real,  and
    count as a special case. Their real parts are stored in locations 0 and N/2
    respectively, while their imaginary parts which are zero are not stored.

    These methods return the FFTed data, and the input data is not changed.

    The following table shows the correspondence between the output ((|self|)) 
    and the equivalent results obtained by considering the input data as a 
    complex sequence with zero imaginary part,

          complex[0].real    =    self[0] 
          complex[0].imag    =    0 
          complex[1].real    =    self[1] 
          complex[1].imag    =    self[N-1]
              ...............         ................
          complex[k].real    =    self[k]
          complex[k].imag    =    self[N-k] 
              ...............         ................
          complex[N/2].real  =    self[N/2]
          complex[N/2].real  =    0
              ...............         ................
          complex[k'].real   =    self[k]        k' = N - k
          complex[k'].imag   =   -self[N-k] 
              ...............         ................
          complex[N-1].real  =    self[1]
          complex[N-1].imag  =   -self[N-1]

--- GSL::Vector#halfcomplex_radix2_inverse
--- GSL::Vector#radix2_inverse
--- GSL::Vector#halfcomplex_radix2_backward
--- GSL::Vector#radix2_backward

    These methods compute the inverse or backwards radix-2 FFT of the
    half-complex sequence data stored according the output scheme used by
    gsl_fft_real_radix2.  The result is a real array stored in natural order.

== Mixed-radix FFT routines for real data

This section describes mixed-radix FFT algorithms for real data. 
The mixed-radix functions work for FFTs of any length. They are a 
reimplementation of the real-FFT routines in the Fortran FFTPACK library 
by Paul Swarztrauber. 
The theory behind the algorithm is explained in the article 
((|Fast Mixed-Radix Real Fourier Transforms|)) by Clive Temperton. 
The routines here use the same indexing scheme and basic algorithms as 
FFTPACK. 

The functions use the FFTPACK storage convention for half-complex sequences.
In this convention the half-complex transform of a real sequence is stored with
frequencies in increasing order, starting at zero, with the real and imaginary
parts of each frequency in neighboring locations. When a value is known to be
real the imaginary part is not stored. The imaginary part of the zero-frequency
component is never stored. It is known to be zero since the zero frequency
component is simply the sum of the input data (all real). For a sequence of
even length the imaginary part of the frequency n/2 is not stored either, since
the symmetry z_k = z_{N-k}^* implies that this is purely real too. 


=== Data storage scheme

The storage scheme is best shown by some examples. 
The table below shows the output for an odd-length sequence, n=5. 
The two columns give the correspondence between the 5 values in the 
half-complex sequence computed (({real_transform})), ((|halfcomplex[]|)) 
and the values ((|complex[]|)) that would be returned if the same real input 
sequence were passed to (({complex_backward})) as a complex sequence 
(with imaginary parts set to 0),

     complex[0].real  =  halfcomplex[0] 
     complex[0].imag  =  0
     complex[1].real  =  halfcomplex[1] 
     complex[1].imag  =  halfcomplex[2]
     complex[2].real  =  halfcomplex[3]
     complex[2].imag  =  halfcomplex[4]
     complex[3].real  =  halfcomplex[3]
     complex[3].imag  = -halfcomplex[4]
     complex[4].real  =  halfcomplex[1]
     complex[4].imag  = -halfcomplex[2]

The upper elements of the ((|complex|)) array, (({complex[3]})) and (({complex[4]}))
are filled in using the symmetry condition. The imaginary part of 
the zero-frequency term (({complex[0].imag})) is known to be zero by the symmetry.

The next table shows the output for an even-length sequence, 
n=5 In the even case there are two values which are purely real,

     complex[0].real  =  halfcomplex[0]
     complex[0].imag  =  0
     complex[1].real  =  halfcomplex[1] 
     complex[1].imag  =  halfcomplex[2] 
     complex[2].real  =  halfcomplex[3] 
     complex[2].imag  =  halfcomplex[4] 
     complex[3].real  =  halfcomplex[5] 
     complex[3].imag  =  0 
     complex[4].real  =  halfcomplex[3] 
     complex[4].imag  = -halfcomplex[4]
     complex[5].real  =  halfcomplex[1] 
     complex[5].imag  = -halfcomplex[2] 

The upper elements of the ((|complex|)) array, (({complex[4]})) 
and (({complex[5]})) are filled in using the symmetry condition. 
Both (({complex[0].imag})) and (({complex[3].imag})) are known to be zero.

==== Wavetable and Workspace classes
--- GSL::FFT::RealWavetable.alloc(n)
--- GSL::FFT::HalfComplexWavetable.alloc(n)

    These methods create trigonometric lookup tables for an FFT of size ((|n|)) 
    real elements. The length ((|n|)) is factorized into a product of subtransforms, 
    and the factors and their trigonometric coefficients are stored in the wavetable.
    The trigonometric coefficients are computed using direct calls to sin and cos, 
    for accuracy. Recursion relations could be used to compute the lookup table 
    faster, but if an application performs many FFTs of the same length then 
    computing the wavetable is a one-off overhead which does not affect the final 
    throughput.

    The wavetable structure can be used repeatedly for any transform of the same 
    length. The table is not modified by calls to any of the other FFT functions. 
    The appropriate type of wavetable must be used for forward real or inverse
    half-complex transforms.

--- GSL::FFT::RealWorkspace.alloc(n)

    This method creates a workspace object for a real transform of length
    ((|n|)).  The same workspace can be used for both forward real and inverse
    halfcomplex transforms.

==== Methods for mixed-radix real FFTs

((*The FFT methods described below return FFTed data, and the input vector is not changed. Use methods with '!' as (({real_tranform!})) for in-place transform.*))

--- GSL::Vector#real_transform(table, work)
--- GSL::Vector#halfcomplex_transform(table, work)
--- GSL::Vector#fft

    These methods compute the FFT of ((|self|)), a real or half-complex array,
    using a mixed radix decimation-in-frequency algorithm.  For
    (({real_transform})) ((|self|)) is an array of time-ordered real data.  For
    (({halfcomplex_transform})) ((|self|)) contains Fourier coefficients in the
    half-complex ordering described above. There is no restriction on the
    length ((|n|)). 

    Efficient modules are provided for subtransforms of length 2, 3, 4 and 5. 
    Any remaining factors are computed with a slow, O(n^2), general-n module. 

    The caller can supply a ((|table|)) containing trigonometric lookup tables 
    and a workspace ((|work|)) (optional).

    These methods return the FFTed data, and the input data is not changed.

--- GSL::Vector#halfcomplex_inverse(table, work)
--- GSL::Vector#halfcomplex_backward(table, work)
--- GSL::Vector#ifft

== Examples

=== Example 1

    #!/usr/bin/env ruby
    require("gsl")
    include GSL

    N = 2048
    SAMPLING = 1000   # 1 kHz
    TMAX = 1.0/SAMPLING*N
    FREQ1 = 50
    FREQ2 = 120
    t = Vector.linspace(0, TMAX, N)
    x = Sf::sin(2*M_PI*FREQ1*t) + Sf::sin(2*M_PI*FREQ2*t)
    y = x.fft

    y2 = y.subvector(1, N-2).to_complex2
    mag = y2.abs
    phase = y2.arg
    f = Vector.linspace(0, SAMPLING/2, mag.size)
    graph(f, mag, "-C -g 3 -x 0 200 -X 'Frequency [Hz]'")

=== Example 2
    #!/usr/bin/env ruby
    require("gsl")
    include GSL

    n = 100
    data = Vector.alloc(n)

    for i in (n/3)...(2*n/3) do
      data[i] = 1.0
    end

    rtable = FFT::RealWavetable.alloc(n)
    rwork = FFT::RealWorkspace.alloc(n)
  
    #ffted = data.real_transform(rtable, rwork)
    #ffted = data.real_transform(rtable)
    #ffted = data.real_transform(rwork)
    #ffted = data.real_transform()
    ffted = data.fft

    for i in 11...n do
      ffted[i] = 0.0
    end
  
    hctable = FFT::HalfComplexWavetable.alloc(n)
  
    #data2 = ffted.halfcomplex_inverse(hctable, rwork)
    #data2 = ffted.halfcomplex_inverse()
    data2 = ffted.ifft

    graph(nil, data, data2, "-T X -C -g 3 -L 'Real-halfcomplex' -x 0 #{data.size}")

((<prev|URL:eigen.html>))
((<next|URL:wavelet.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
