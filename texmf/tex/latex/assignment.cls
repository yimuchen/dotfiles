\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{assignment}[Template for common assignment layout]
\LoadClass[a4paper, fontsize=12pt]{scrartcl}

%% Title parts
\newcommand*{\assignment}[1]{\gdef\@assignment{#1}}
\newcommand*{\@assignment}{Assignment X}

\newcommand*{\course}[1]{\gdef\@course{#1}}
\newcommand*{\@course}{Course}

\renewcommand*{\maketitle}{%
\begin{center}
\textbf{\textsc{\@course}}\\
\@assignment\quad\@date
\end{center}
}

%% Header and footer part
\RequirePackage[automark]{scrlayer-scrpage}

\newcommand*{\studentid}[1]{\gdef\@studentid{#1}}
\newcommand*{\@studentid}{student id}

\clearpairofpagestyles
\cfoot[\pagemark]{\pagemark}
\ihead{\textup{\@studentid}}
\ohead{\textup{\@author}}
\pagestyle{scrheadings}

%% Problem listing (alters the equation and figure listing numbers)
\newcommand*{\problem}[2]{
  \gdef\@problem{#1}
  \setcounter{equation}{0}
  \setcounter{figure}{0}
  \vspace{5mm}
  \vbox{
  \hrule height 0.3mm
  \vspace{1mm}
  \noindent\textbf{[\@problem]}\quad {#2}
  \vspace{1mm}
  \hrule height 0.3mm}
  \vspace{2mm}
}
\newcommand*{\@problem}{Problem 1}

\renewcommand{\theequation}{\@problem-\arabic{equation}}
\renewcommand{\thefigure}{\@problem-\arabic{figure}}
