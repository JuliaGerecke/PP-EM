# Error Mitigation on Quantum Dynamics using Pauli Propagation

This repository is the result of a project conducted by Julia Gerecke and Julia Guignon in Pr. Zoë Holmes' lab at EPFL. Julia Gerecke completed her specialization semester (30 ECTS), while Julia Guignon was working on her Physics Project II (8 ECTS). The project was supervised by Manuel Rudolph and Tyson Ray Jones. 

With this repo, you can perform error mitigation using the classical simulation library $`\texttt{PauliPropagation.jl}`$ in Julia. The central implemented error mitigation schemes include:

- Zero Noise Extrapolation (ZNE)
- Clifford Data Regression (CDR)
- variable noise CDR (vnCDR)
- Clifford Perturbation Approximation (CPA) and Clifford Perturbation Data Regression- ZNE (CPDR-ZNE)

To gain an overview of the concept of error mitigation for trotterized circuits, refer to the $`\texttt{introduction-example-error-mitigation.ipynb}`$.
In the notebook $`\texttt{advanced-example-error-mitigation.ipynb}`$, we show how to use our code base for the error mitigation techniques mentioned above.
We compared our error mitigation results with those of IBM's utility experiment (2023) for ZNE error mitigation. These can be found at the end of  $`\texttt{introduction-example-error-mitigation.ipynb}`$. For an implementation in a julia file, refer to $`\texttt{IBM\_utility\_exp\_4b\_data\_generation.jl}`$.
