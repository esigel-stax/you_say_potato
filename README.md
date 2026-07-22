# You Say Potato, I Say

**The Post-Columbian Divergence in European Economic and Ideological Development**

Eleanor Sigel · Stanford University · June 2026

📄 [Read the paper](paper/you_say_potato.pdf) · 🌐 [Project website](https://<your-github-username>.github.io/<repo-name>/)

## Abstract

This paper exploits spatial data mapping agricultural suitability for potato cultivation to examine the impact of the crop's post-Columbian introduction on the development of European socio-economic inequality in the succeeding centuries. Building on Nunn and Qian (2011), I extend this previous work along two dimensions: (i) I link potato suitability to civic group membership, patterns of political and cultural values, and, most centrally, a respondent-level communal-individual belief index, relying upon the EVS5/WVS7 Joint Survey; (ii) I shift the focus from levels of income to inequality in income, measuring within-area dispersion of income, proxied by urbanization, and physical welfare, proxied by height. Under the preferred specification, a one-within-country-SD increase in potato suitability raises the communal-index by roughly 0.20σ, lowers the within-region SD of ln(city pop 1850) by 0.16σ, and lowers the within-département SD of conscript height by 0.4σ. Civic engagement is uncorrelated with potato suitability under this design, suggesting the underlying mechanism is unrelated to prosocial behavior.

## Headline results

| Outcome | β (ln wpot) | SE | p | R² | N | Specification |
|---|---:|---:|---:|---:|---:|---|
| Communal-individual belief index | +0.0058** | (0.0025) | 0.027 | 0.868 | 98 | NUTS-1, country FE + ln oworld |
| Communal-individual belief index | +0.0047* | (0.0024) | 0.061 | 0.744 | 216 | NUTS-2, country FE + full geog |
| Civic engagement (membership share) | −0.0017 | (0.0037) | 0.651 | 0.795 | 216 | NUTS-2, country FE + full geog |
| Income dispersion: SD ln(pop 1850) | −0.0498*** | (0.0149) | 0.003 | 0.209 | 179 | NUTS-2, country FE + full geog |
| France height: within-département SD | −0.0816*** | (0.0225) | 0.001 | 0.167 | 36 | département level, + old-world idx |

\* p < .10, \*\* p < .05, \*\*\* p < .01. See the paper for the full specification ladders.

## Repository structure

```
paper/     the compiled paper (PDF)
docs/      GitHub Pages website (index.html) presenting the project
figures/   the paper's exhibits (Europe & France maps, binscatters)
code/      LaTeX source for the paper and Stata do-files for the analysis
data/      not included — see data/README.md for how to obtain each source
```

## Data

Three datasets underlie the analysis; none are redistributed in this repository because of licensing/access terms. See [`data/README.md`](data/README.md) for exact sources and access instructions:

- **EVS5/WVS7 Joint Survey v5.0.0** (GESIS Data Archive, ZA7505) — registration required
- **Nunn and Qian (2011) replication archive** (country panel, Europe city panel, France conscript-height microdata) — publicly available
- **Eurostat NUTS-1/NUTS-2 boundary GeoJSON** (2021 vintage) — publicly available

## Reproducing the analysis

The `code/` folder contains the Stata do-files (`beliefs.do`, `Replication_*.do`) used to build the regional and France-conscript results, and the LaTeX source (`potato_paper_dropin.tex` plus its included files) used to typeset the paper. Point the do-files at the data sources described in `data/README.md` and run in Stata 14+.

## Citation

Nunn, N. and Qian, N. (2011). The potato's contribution to population and urbanization: Evidence from a historical experiment. *Quarterly Journal of Economics*, 126(2):593–650.

## License

Code in this repository (`code/`) is released under the MIT License — see [LICENSE](LICENSE). The paper text and figures are © Eleanor Sigel; please contact esigel@stanford.edu for reuse beyond fair use.
