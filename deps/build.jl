using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libgeos_c"], :libgeos),
    LibraryProduct(prefix, String["libgeos"], :libgeos_cpp),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaGeo/GEOSBuilder/releases/download/v3.6.2-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/GEOS.aarch64-linux-gnu.tar.gz", "bdd07a586bfd952f92ac939e5372b651af16982b542a27252ca5704c3c73dbd7"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/GEOS.arm-linux-gnueabihf.tar.gz", "94bb0679bb6a02b5a75a6c2727053816ed4edf8678df89dc3637d62fcd23ae21"),
    Linux(:i686, :glibc) => ("$bin_prefix/GEOS.i686-linux-gnu.tar.gz", "bb4e67f8a9b81eca7edf6f41c1eaddaf171398810a2b2cd0b6d272b96550ec57"),
    Windows(:i686) => ("$bin_prefix/GEOS.i686-w64-mingw32.tar.gz", "c3e2e8867d7af852dd5696d0eabe87449fce29853c7fa4b8e809cb86f1e4bcec"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/GEOS.powerpc64le-linux-gnu.tar.gz", "8ea4bce7bc613c4f4a7541173844b12e1ba6d18836e7b09955cf5503a49de3c8"),
    MacOS(:x86_64) => ("$bin_prefix/GEOS.x86_64-apple-darwin14.tar.gz", "93eecb3f0a0336feb46b8bb899684d50b9025b7e4703dfca81e7ea10eb021d2b"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/GEOS.x86_64-linux-gnu.tar.gz", "602f759fa580346f59f4b50713e82621ac34ddb397a69ef608b24ab6761223ce"),
    Windows(:x86_64) => ("$bin_prefix/GEOS.x86_64-w64-mingw32.tar.gz", "b3d1713345a73b230065281ebccd7867d952b5369ae64da2919b05b9c40e248a"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
