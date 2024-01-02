%% Customize class for creating a single tikz figure (boards will be cropped the minimum size
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tikzfigure}[Figure for drawing standalone figures with tikz]

\LoadClass{standalone}

%% Loading additional libraries
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{tikz}
\RequirePackage[american]{circuitikz}
\RequirePackage{fontspec}
\RequirePackage{unicode-math}
\RequirePackage{amsmath}
