# The Shovel package

Shovel is a Julia package based on Snowflake from Anyon Systems. Its aim is to provide useful tool for researchers and studants wishing to learn more on quantum computing. The package was developped as a hobby while I was learning how to use a quantum computer to be installed at our Calcul Québec data center. While reading and trying the Snowflake package I often felt unsure that I had fully understood what was going on. So I started to develop a few tools to confirm my understanding. I also felt that many outputs were difficult to document and the process of building quantum circuits was a bit tedious. Hence the Shovel package to enhance Snowflake.

## Shovel components

The package consist of three main components.
    - A LaTeX conversion section allowing researchers to easily convert Snowflake circuits into ASCII text easy to integrate into LaTeX document using the Quantikz package.
    - A easy to use system sequantial system allowing users to generate shots of the circuits in an optimal fashion.
    - A Meta Quantum Circuit (shMQC) concept, used to create new circuits by plugging together smaller circuits.

Most functions and structures are prefixed by "sh" (for "shovel") to avoid confusion with Snowflake and to clearly identify them.

## Links

Documentation on the functions of the package is [here.](https://recherchestochastique.github.io/Shovel/build/index.html).

Users will also find additional documents explaining the ideas behind the construction of the package. They are references at the bottom of the documentation but can be directly accessed using the following links:
    - [Sequential estimation](https://recherchestochastique.github.io/Shovel/build/Stop/index.html)
    - [LaTeXe conversion](https://recherchestochastique.github.io/Shovel/build/ToLaTeX/index.html)

I hope you will find this package helpful given the amount of time I have spend learning the Julia language and its Documenter package, Github integration with VS Code on top of the knowledge I had to acquire to understand quantum computing.

Denys Gagnon M.Sc
Sr. Project Manager
Calcul Québec
