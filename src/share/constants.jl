

const T_fw_frz = 273.15              # Freeze point of freshwater in Kelvin
const T_sw_frz = T_fw_frz - 1.8      # Freeze point of seawater in Kelvin

const T_ref = T_fw_frz + 20.0        # Reference temperature of thermal expansion coefficient / salinity coefficient
const S_ref = 35e-3                  # Reference salinity    of thermal expansion coefficient / salinity coefficient
const α   = 3e-4     # K^-1    http://www.kayelaby.npl.co.uk/general_physics/2_7/2_7_9.html
const β   = 1e-3     # Simple estimation
const c_p = 3985.0   # J / kg / K
const ρ   = 1027.0   # kg / m^3
const g   = 9.8      # m / s^2

const αgρc = α * g / (ρ * c_p)

const b_sw_frz = α * (T_sw_frz - T_ref)

const missing_value = 1e20