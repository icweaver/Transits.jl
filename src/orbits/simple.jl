struct SimpleOrbit{T,V,S} <: AbstractOrbit
    period::T
    t0::T
    b::V
    duration::T
    speed::S
    half_period::T
    ref_time::T
    r_star::V
end

"""
    SimpleOrbit(; period, duration, t0=0, b=0.0, r_star=1.0)

Circular orbit parameterized by the basic observables of a transiting system.

# Parameters
* `period` - The orbital period of the planets, nominally in days
* `duration` - The duration of the transit, similar units as `period`.
* `t0` - The midpoint time of the reference transit, similar units as `period`
* `b` - The impact parameter of the orbit, unitless
* `r_star` - The radius of the star, defaults to 1 solar radius
"""
function SimpleOrbit(;period, duration, t0=zero(period), b=0.0, r_star=1.0)
    half_period = 0.5 * period
    duration > half_period && error("duration cannot be longer than half the period")
    speed = 2.0 * sqrt(1.0 - b^2.0) / duration
    ref_time =  t0 - half_period
    # normalize time types
    period, t0, duration, half_period, ref_time = promote(
    period, t0, duration, half_period, ref_time, r_star
    )
    SimpleOrbit(period, t0, b, duration, speed, half_period, ref_time, r_star)
end


period(orbit::SimpleOrbit) = orbit.period
duration(orbit::SimpleOrbit) = orbit.duration

relative_time(orbit::SimpleOrbit, t) = mod(t - orbit.ref_time, period(orbit)) - orbit.half_period

function relative_position(orbit::SimpleOrbit, t)
    Δt = relative_time(orbit, t)
    x = orbit.speed * Δt
    y = orbit.b
    z = sign(Δt + orbit.half_period/2.0) # Start at t₀
    return SA[x*orbit.r_star, y*orbit.r_star, z]
end

# TODO: if texp, tol += 0.5 * texp
function in_transit(orbit::SimpleOrbit, t)
    Δt = relative_time.(orbit, t)
    ϵ = 0.5 * orbit.duration
    return findall(x -> abs(x) < ϵ, Δt)
end
function in_transit(orbit::SimpleOrbit, t, r)
    Δt = relative_time.(orbit, t)
    ϵ = √((orbit.r_star + r)^2.0 - orbit.b^2.0) / orbit.speed
    return findall(x -> abs(x) < ϵ, Δt)
end

function flip(orbit::SimpleOrbit, ror)
    t0 = orbit.t0 + orbit.half_period
    b = orbit.b / ror
    speed = orbit.speed / ror
    ref_time = orbit.t0
    return SimpleOrbit(
        orbit.period, t0, b, orbit.duration, speed, orbit.half_period, ref_time, orbit.r_star
    )
end

function Base.show(io::IO, orbit::SimpleOrbit)
    T = orbit.duration
    P = orbit.period
    b = orbit.b
    t0 = orbit.t0
    r_star = orbit.r_star
    print(io,
        "SimpleOrbit(P=$P, T=$T, t0=$t0, b=$b, r_star=$r_star)"
    )
end

function Base.show(io::IO, ::MIME"text/plain", orbit::SimpleOrbit)
    T = orbit.duration
    P = orbit.period
    b = orbit.b
    t0 = orbit.t0
    r_star = orbit.r_star
    print(io,
        "SimpleOrbit\n period: ", P,
        "\n duration: ", T,
        "\n t0: ", t0,
        "\n b: ", b,
        "\n r_star: ", r_star,
    )
end
