merge!(overwrite_configs, Dict(
    :MLD_scheme                   => :prognostic,
    :Qflux_scheme                 => :energy_flux,
    :Qflux_finding                => :off,
    :vertical_diffusion_scheme    => :off,
    :horizontal_diffusion_scheme  => :off,
    :relaxation_scheme            => :on,
    :convective_adjustment_scheme => :on,
    :radiation_scheme             => :exponential,
    :advection_scheme             => :static,
))
