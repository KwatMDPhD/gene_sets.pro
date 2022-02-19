### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ 0e90981e-9027-11ec-0f84-3b15ad492e49
begin

    using Pkg

    Pkg.activate(Base.current_project())

end

# ╔═╡ 4858b495-d3b2-4ded-ba87-97e4143e5a27
begin

    using LeanProject

    se = joinpath("..", "input", "setting.json")

    PAR, PAI, PAC, PAO = LeanProject.get_project_path(se)

    SE = LeanProject.read_setting(se)

end

# ╔═╡ b20410d3-9a6d-4014-b24a-4a54f1f43161
begin

    using OnePiece
    using XMLDict

end

# ╔═╡ d86431e2-0c50-4653-a723-0afd94519e62
xm = "msigdb_v7.5.1.xml"

# ╔═╡ a17e034f-72a6-4eec-857f-e724ef1b5ebc
begin

    println("Parsing $xm")

    ca_se_di = Dict()

    en = "GENESET"

    for (id, li) in enumerate(readlines(joinpath(PAI, xm)))

        if !startswith(li, "<$en")

            continue

        end

        di = xml_dict(li)[en]

        ca = di[:CATEGORY_CODE]

        if !haskey(ca_se_di, ca)

            ca_se_di[ca] = Dict()

        end

        se_di = Dict(
            "Organism" => di[:ORGANISM],
            "Description" => di[:DESCRIPTION_BRIEF],
            "URL" => di[:EXTERNAL_DETAILS_URL],
            "ENSGs" => di[:MEMBERS],
            "Symbols" => di[:MEMBERS_SYMBOLIZED],
        )

        ca_se_di[ca][di[:STANDARD_NAME]] = se_di

    end

    for (ca, se_di) in ca_se_di

        println("$ca has $(length(se_di)) sets.")

    end

end

# ╔═╡ aef5a50e-6807-4a67-8aaa-759c4a7742de
OnePiece.dict.write(joinpath(PAO, replace(xm, ".xml" => ".json")), ca_se_di)


# ╔═╡ 04bc477a-d93a-4397-b853-f0693236a91c
ge_ = OnePiece.table.read(
    "../../find_human_gene.pro/output/human_lymphocyte_gene_by_information.tsv",
)[
    !,
    1,
]

# ╔═╡ b8ab30ec-6b72-4ea1-aaa5-f33956c814b1
begin

    ge_ca_se_ = Dict()

    for ge in ge_

        ca_se_ = Dict()

        for (ca, se_di) in ca_se_di

            se_ = []

            for (se, di) in se_di

                sy_ = di["Symbols"]

                if di["Organism"] != "Homo sapiens" || 200 < length(sy_)

                    continue

                end

                if occursin(ge, sy_)

                    push!(se_, se)

                end

            end

            ca_se_[ca] = se_

        end

        ge_ca_se_[ge] = ca_se_

    end

end

# ╔═╡ 5c414b57-173f-4fd2-b144-ab67fc828994
ca_ti = Dict(
    "H" => "Hallmark Gene Sets",
    "C1" => "Positional Gene Sets",
    "C2" => "Curated Gene Sets",
    "C3" => "Regulatory Target Gene Sets",
    "C4" => "Computational Gene Sets",
    "C5" => "Ontology Gene Sets",
    "C6" => "Oncogenic Signature Gene Sets",
    "C7" => "Immunologic Signature Gene Sets",
    "C8" => "Cell Type Signature Gene Sets",
)


# ╔═╡ 41affb5c-10e6-4310-9619-d88769d5c3a8
open(joinpath(PAO, "gene_sets.md"), "w") do io

    for (ge, ca_se_) in ge_ca_se_

        write(io, "## $ge\n\n")

        for (ca, se_) in ca_se_

            if ca in ["C1", "C4", "ARCHIVED"]

                continue

            end

            if isempty(se_)

                continue

            end

            write(io, "#### $(ca_ti[ca])\n\n")

            for (id, se) in enumerate(sort(se_))

                write(io, " $id. [$se]($(ca_se_di[ca][se]["URL"]))\n\n")

            end

        end

    end

end

# ╔═╡ Cell order:
# ╠═0e90981e-9027-11ec-0f84-3b15ad492e49
# ╠═4858b495-d3b2-4ded-ba87-97e4143e5a27
# ╠═a17e034f-72a6-4eec-857f-e724ef1b5ebc
# ╠═d86431e2-0c50-4653-a723-0afd94519e62
# ╠═b20410d3-9a6d-4014-b24a-4a54f1f43161
# ╠═aef5a50e-6807-4a67-8aaa-759c4a7742de
# ╠═04bc477a-d93a-4397-b853-f0693236a91c
# ╠═b8ab30ec-6b72-4ea1-aaa5-f33956c814b1
# ╠═5c414b57-173f-4fd2-b144-ab67fc828994
# ╠═41affb5c-10e6-4310-9619-d88769d5c3a8
