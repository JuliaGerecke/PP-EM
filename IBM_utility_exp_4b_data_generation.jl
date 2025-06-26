include("pp-em.jl")

### This file runs in roughly 2 min on my laptop with the current truncation coefficients (min_abs_coeff, min_abs_coeff_noisy, max_weight = 1e-4,1e-4,8).
### DISCLAIMER: Be midful when lowering the truncation levels, your memory will quickly saturate.

function IBM_utility_exp_4b_all()
    global_logger(UnbufferedLogger(stdout,SubInfo))
    
    nq = 127
    nl = 20
    dt = 0.05 
    T = nl*dt
    J = π/2
    topology = ibmeagletopology

    mixed_angles = [0.3,1.0,0.7,0.0,0.2,0.8,0.5,0.1,0.4,1.5707,0.6]
    h_values = mixed_angles .* nl/(2*T)
    
    IBM_unmitigated_vals =  [ 0.4188991191900761,
    0.004107759335343423,
    0.11944580478416555,
    0.49038646460776864,
    0.4552471452020139,
    0.055064655494323766,
    0.3061535376123831,
    0.4889782663914668,
    0.3622122171682965,
   -0.001980699802309258,
    0.20175539633925924]
    
    noise_kind="both"; angle_definition=π/20
    min_abs_coeff, min_abs_coeff_noisy, max_weight = 1e-4,1e-4,8
    depol_strength = 0.02
    dephase_strength = 0.02
    noise_levels=[1.0,1.3,1.5,1.8,2.0,2.2]; lambda=0.0; use_target=false
    
    observable = PauliSum(nq); add!(observable,:Z,62)
    # observable = PauliSum(nq); add!(observable,:Z,1)
    collect_exact = Float64[]; collect_noisy = Float64[]
    collect_zne = Float64[]; collect_cdr = Float64[]; collect_vncd = Float64[]
    collect_vncd_lin = Float64[]; collect_zne_lin = Float64[]

    layer = kickedisingcircuit(nq, 1; topology=topology)
    for (i,h) in enumerate(h_values)
        training_set = training_circuit_generation_strict_perturbation(layer, J, h, dt, angle_definition; sample_function="small", num_samples=10)

        exact, noisy,
        zne_corr,zne_corr_lin, cdr_corr, vn_corr, vn_corr_lin,
        _, _, _,_,_,
        _, _, _,_,_ = full_run_all_methods(
            nq, nl, topology, layer, J, h, dt, angle_definition, noise_kind;
            min_abs_coeff=min_abs_coeff, max_weight=max_weight,
            min_abs_coeff_noisy=min_abs_coeff_noisy,
            training_set=training_set, observable=observable,
            num_samples=10,
            depol_strength=depol_strength,
            dephase_strength=dephase_strength,
            noise_levels=noise_levels, lambda=lambda,
            use_target=use_target,
            real_qc_noisy_data=IBM_unmitigated_vals[i], record_fit_data = false, fit_type="exponential", fit_intercept = false
        )
        
        push!(collect_exact, exact)
        push!(collect_noisy, noisy)
        push!(collect_zne, zne_corr)
        push!(collect_zne_lin, zne_corr_lin)
        push!(collect_cdr, cdr_corr)
        push!(collect_vncd, vn_corr)
        push!(collect_vncd_lin, vn_corr_lin)
    end
    
     # log file for this utility run, stamped with current datetime
     run_ts = Dates.format(Dates.now(), "YYYYmmdd_HHMMSS")
     logfname = "tfim_utility_nq=$(nq)_angle_def=$(round(angle_definition;digits = 3))_$(run_ts).log"
     
    # write summary table to log
    open(logfname, "a") do io
        # header
        println(io, "idx,h_value,Exact_targets,Noisy_targets,ZNE_outputs,ZNE_outputs_lin,CDR_outputs,vnCDR_outputs, vnCDR_outputs_lin")
        # rows
        for i in eachindex(collect_exact)
            println(io, join((
                i,
                h_values[i],
                collect_exact[i],
                collect_noisy[i],
                collect_zne[i],
                collect_zne_lin[i],
                collect_cdr[i],
                collect_vncd[i],
                collect_vncd_lin[i]
            ), ","))
        end
    end

    
    #save the results as a figure

    # Mitigated values
    IBM_mitigated_vals = [1.01688859, 1.00387483, 0.95615886, 0.95966435, 0.83946763,
    0.81185907, 0.54640995, 0.45518584, 0.19469377, 0.01301832,0.01016334] 
    IBM_angles = [0.    , 0.1   , 0.2   , 0.3   , 0.4   , 0.5   , 0.6   , 0.7   , 0.8   , 1.    , 1.5707]


    # Flatiron tensor network values used as the most precised values known 
    tn_vals = [9.99999254e-01,  9.99593653e-01,  9.95720077e-01,  9.88301532e-01,
        9.78553511e-01,  9.58023054e-01,  9.21986059e-01,  8.81726079e-01,
        8.49816779e-01,  8.24900527e-01,  7.91257641e-01,  7.37435202e-01,
        6.68573798e-01,  5.88096040e-01,  4.81874079e-01,  3.50316579e-01,
        2.26709331e-01,  1.39724659e-01,  7.86639143e-02,  4.24124371e-02,
        1.90595136e-02,  6.18879050e-03, -8.27168956e-04, -4.63372099e-03,
       -7.05202121e-03, -7.68387421e-03, -6.33121142e-03, -4.32594440e-03,
        6.52050191e-04,  1.72598340e-04,  5.64696020e-05, -7.70582375e-07]
    tn_angles = LinRange(0, π/2, length(tn_vals));
    scatter(mixed_angles, IBM_unmitigated_vals, label=L"\textrm{IBM\ QC\ Unmitigated}", marker=:diamond, 
                color=:blue, lw=2, 
                guidefontsize=16,
                tickfontsize=12,
                legendfontsize=12, ms=6)
    scatter!(IBM_angles, IBM_mitigated_vals, label=L"\textrm{IBM\ QC\ ZNE\ Mitigated}", color="Red", ms=6, marker=:diamond)
    plot!(tn_angles, tn_vals, label=L"\textrm{Flatiron\ Tensor\ Network}", color="grey", alpha=0.8, linewidth=3, ms=6)


    # CPA / CDR
    scatter!(mixed_angles, collect_cdr, label=L"\textrm{CDR\ correction}", color="lightgreen", linewidth=3,ms=6, marker=:o, alpha=0.7)
    # ZNE
    scatter!(mixed_angles, collect_zne, label=L"\textrm{ZNE\ correction}", color="lightblue",ms=6, marker=:o, alpha=0.7)

    # vnCDR exponential (this can lie outside the range of reasonable values [0,1])
    #scatter!(mixed_angles, collect_vncd, label=L"\textrm{vnCDR\ exp. correction}", color="orange",ms=6, marker=:o, alpha=0.7)
    # vnCDR linear
    scatter!(mixed_angles, collect_vncd_lin, label=L"\textrm{vnCDR\ linear\ correction}", color="purple",ms=6, marker=:o, alpha=0.7)
    
    plot!(legend_position=(0.6, 0.8), xlabel=L" R_X\  \textrm{angle}\ \theta_h",
            ylabel=L"<Z_{62}>", size=(610,450), dpi=300)

    savefig("IBM_utility_exp_4b_nq=$(nq)_angle_def=$(round(angle_definition;digits = 3)).png")
end
    IBM_utility_exp_4b_all()
    println("done")