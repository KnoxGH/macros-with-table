import Foundation

/// An iterative radix-2 Cooley-Tukey FFT with no external DSP dependency, used
/// to keep TableMacroCore importable on any platform without Accelerate.
enum Radix2FFT {
    /// Applies a Hann window, zero-pads to the next power of two, and returns
    /// the one-sided power spectrum (bins `0...size/2`).
    static func powerSpectrum(_ input: [Double], size requestedSize: Int? = nil) -> [Double] {
        let desired = requestedSize ?? input.count
        let size = nextPowerOfTwo(max(desired, 2))
        var real = Array(repeating: 0.0, count: size)
        var imaginary = Array(repeating: 0.0, count: size)
        let copied = min(input.count, size)

        if copied > 1 {
            for index in 0..<copied {
                let window = 0.5 - 0.5 * cos(2 * Double.pi * Double(index) / Double(copied - 1))
                real[index] = input[index] * window
            }
        }

        bitReverse(&real, &imaginary, size: size)
        butterfly(&real, &imaginary, size: size)

        return (0...(size / 2)).map { index in
            (real[index] * real[index] + imaginary[index] * imaginary[index]) / Double(size)
        }
    }

    static func nextPowerOfTwo(_ value: Int) -> Int {
        var result = 1
        while result < value { result <<= 1 }
        return result
    }

    private static func bitReverse(_ real: inout [Double], _ imaginary: inout [Double], size: Int) {
        var j = 0
        for i in 1..<size {
            var bit = size >> 1
            while j & bit != 0 {
                j ^= bit
                bit >>= 1
            }
            j ^= bit
            if i < j {
                real.swapAt(i, j)
                imaginary.swapAt(i, j)
            }
        }
    }

    private static func butterfly(_ real: inout [Double], _ imaginary: inout [Double], size: Int) {
        var length = 2
        while length <= size {
            let angle = -2 * Double.pi / Double(length)
            let baseReal = cos(angle)
            let baseImaginary = sin(angle)
            var start = 0
            while start < size {
                var wReal = 1.0
                var wImaginary = 0.0
                for offset in 0..<(length / 2) {
                    let even = start + offset
                    let odd = even + length / 2
                    let oddReal = real[odd] * wReal - imaginary[odd] * wImaginary
                    let oddImaginary = real[odd] * wImaginary + imaginary[odd] * wReal
                    real[odd] = real[even] - oddReal
                    imaginary[odd] = imaginary[even] - oddImaginary
                    real[even] += oddReal
                    imaginary[even] += oddImaginary
                    let nextReal = wReal * baseReal - wImaginary * baseImaginary
                    wImaginary = wReal * baseImaginary + wImaginary * baseReal
                    wReal = nextReal
                }
                start += length
            }
            length <<= 1
        }
    }
}
