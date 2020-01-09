using Random: seed!
seed!(1)

include("data.jl")

data = get_data()

using Turing

Turing.setadbackend(:reverse_diff)

include("model.jl")

model = get_model(data["image"], data["label"], data["D"], data["N"], data["C"])

alg = HMC(0.1, 4)
n_samples = 2_000

include("../infer.jl")

# Save result

if !isnothing(chain)
    using BSON

    m_data = chain[:m].value.data

    m_bayes = mean(
        map(
            i -> reconstruct(pca, Matrix{Float64}(reshape(m_data[i,:,1], D_pca, 10))), 
            1_000:100:2_000
        )
    )

    bson("result.bson", m_bayes=m_bayes)
end