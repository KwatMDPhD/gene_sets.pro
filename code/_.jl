using Revise
using BenchmarkTools

using LeanProject

# ========================
se = joinpath("..", "input", "setting.json")

PAR, PAI, PAC, PAO = get_project_path(se)

SE = read_setting(se)

# ========================
using DictExtension
using GMTAccess
using TableAccess
