(*<*)
theory EnumArbolesBinariosIngles
imports T10MaximalHintikkaIngles 
begin
(*>*)

section \<open> Enumeración de fórmulas proposicionales \<close>

text \<open>
  \label{enumeration} 

  En esta sección mostramos una manera de enumerar, las fórmulas de
  cualquier lenguaje de la lógica proposicional.  La enumeración
  (definición \ref{enumerar}) está basada en representar las fórmulas
  por medio de árboles binarios de números naturales.  De esta forma, si
  se tiene una numeración del conjunto de árboles binarios entonces se
  tiene una numeración del conjunto de fórmulas del lenguaje dado.

  Recordemos que una enumeración de un conjunto $A$ es cualquier función
  sobreyectiva $f\colon \mathbb{N}\to A$ definición (\ref{enumerar}).

  En forma equivalente, los siguientes dos lemas demuestran que, una
  función \linebreak
  $f\colon \mathbb{N}\to A$ es una numeración si existe una función $g$
  inversa por derecha de $f$. 

  \begin{lema}\label{enum1}
  Si $f$ es una funcíon sobreyectiva entonces, existe una función $g$
  inversa por derecha de $f$. 
  \end{lema}

  \noindent Su formalización es
\<close>

lemma enum1:
  assumes "(\<forall>y.\<exists>x. y = (f x))"
  shows "\<exists>g. \<forall>y. f(g y) = y"
(*<*)
proof -
  fix y
  { have "\<forall>y. y = f (SOME x. y = (f x))"  
    proof(rule allI)
      fix y
      obtain x where x: "y= (f x)" using assms by auto
      thus "y = f (SOME x. y = (f x))" by (rule someI)
    qed }
  hence "\<forall>y. f((\<lambda>y. SOME x. y = (f x)) y) = y" by simp
  thus "\<exists>g. \<forall>y. f(g y) = y"
    by (rule_tac x = "(\<lambda>y. SOME x. y = (f x)) " in exI)
qed 

(*>*)
text \<open>
  \begin{lema}\label{enum2}
  Si la función $f$ tiene una inversa por derecha entonces, $f$ es
  sobreyectiva. 
  \end{lema}

  \noindent Su formalización es
\<close>
 
lemma enum2:
  assumes  "\<forall>x. f(g x) = x"
  shows "\<forall>y.\<exists>x. y = f x"
(*<*)
proof -  
  { fix y
    have "\<exists>x. y = f x" using assms by(rule_tac x= "g y" in exI) simp } 
  thus "\<forall>y.\<exists>x. y = f x" by auto
qed

(*>*)
text \<open> 
  Así, tenemos otra forma equivalente de definir la noción de
  numeración la cual se utilizará en esta sección: 

  \begin{lema}\label{enumera}
  $f\colon \mathbb{N}\to A$ es una numeración siysi tiene una inversa
  por derecha. 
  \end{lema}

  \noindent Su formalización es
\<close>

lemma enumeration: "enumeration f = (\<exists>g. \<forall>y. f(g y) = y)"
using enum1 enum2 
by (unfold enumeration_def) blast

subsection \<open> Enumeración de árboles binarios \<close>

text \<open>
  \label{sec:enumeration} 

  En esta sección mostramos una manera de numerar los árboles binarios.
  Conside\-raremos formalmente el tipo de dato {\em árbol binario} donde
  sus elementos son árboles binarios cuyas hojas son números naturales.
\<close>

datatype arbolb = Hoja nat | Arbol arbolb arbolb

(*
definition numerable :: "'b set  \<Rightarrow> bool" where
  "numerable A = (\<exists>(f:: (nat set) \<Rightarrow> A). surj f)" 
*)

text \<open>
  La numeración del tipo de dato árbol binario está basada en una
  numeración del producto cartesiano $\mathbb{N}\times \mathbb{N}$ de
  los números naturales.
\<close>

subsubsection \<open> 
  Numeración del producto cartesiano $\mathbb{N}\times \mathbb{N}$ 
\<close>
 
text \<open>
  Una forma de listar $\mathbb{N}\times \mathbb{N}$ es la siguiente: 

  $\begin{array}{llll}
    (0,0),  &        &        &        \\
    (0,1),  & (1,0), &        &        \\
    (0,2),  & (1,1), & (2,0), &        \\
    (0,3),  & (1,2), & (2,1), & (3,0), \\ 
     ....   &        &        &
  \end{array}$

  Es decir, se listan por la suma de sus componentes y los que tienen
  la misma suma se ordenan por su primera componente. La función {\em
  diag}, que le asigna a cada número natural el par que ocupa la
  posición $n$ en la anterior ordenación, se puede definir por recursión
  como sigue:

  \begin{enumerate}
      \item $diag(0)=(0,0)$
      \item $diag(n+1) = 
              \begin{cases}             
                (0, x+1), & \mbox{si $diag(n)= (x,0)$}\\ 
                (x+1, y), & \mbox{si $diag(n)= (x, y+1)$}                 
              \end{cases}$    
  \end{enumerate}

  \noindent Su formalización es
\<close>

primrec diag :: "nat \<Rightarrow> (nat \<times> nat)" where
  "diag 0 = (0, 0)"
| "diag (Suc n) =
     (let (x, y) = diag n
      in case y of
          0 \<Rightarrow> (0, Suc x)
        | Suc y \<Rightarrow> (Suc x, y))"

text \<open> 
  Para demostrar que @{text "diag"} es sobreyectiva, definimos la
  siguiente función {\em undiag} inversa (por derecha) de @{text
  "diag"}, 
  \begin{enumerate}
      \item $undiag(0, 0) = 0$
      \item $undiag(0, y+1) = undiag(y,0)+1$
      \item $undiag(x+1, y) = undiag(x,y+1)+1$
  \end{enumerate}
\<close>

function undiag :: "nat \<times> nat \<Rightarrow> nat" where
  "undiag (0, 0) = 0"
| "undiag (0, Suc y) = Suc (undiag (y, 0))"
| "undiag (Suc x, y) = Suc (undiag (x, Suc y))"
by pat_completeness auto

termination
  by (relation "measure (\<lambda>(x, y). ((x + y) * (x + y + 1)) div 2 + x)") auto

text \<open> 
  Nótese que la función de medida de la función {\em undiag} está
  definida justamente por la expresión que define explícitamente a la
  función {\em undiag}.
\<close>

text \<open> 
  El siguiente resultado demuestra que {\em undiag} es inversa por
  derecha de {\em diag.} 
\<close>

lemma diag_undiag [simp]: "diag (undiag (x, y)) = (x, y)"
by (rule undiag.induct) (simp add: Let_def)+

text \<open> 
  De esta forma, se tiene que  la función {\em diag} es una numeración
  de $\mathbb{N}\times \mathbb{N}$. Formalmente: 
\<close>

lemma enumeration_natxnat: "enumeration (diag::nat \<Rightarrow> (nat \<times> nat))"
proof -
  have "\<forall>x y. diag (undiag (x, y)) = (x, y)" using diag_undiag by auto
  hence "\<exists>undiag. \<forall>x y. diag (undiag (x, y)) = (x, y)" by blast
  thus ?thesis using enumeration[of diag] by auto
qed

subsubsection \<open> Enumeración del tipo de dato árbol binario  \<close>

text \<open> 
  \label{enumarbolb}


  Con base a la enumeración @{text "diag"} del producto cartesiano
  $\mathbb{N}\times \mathbb{N}$, definimos la siguiente enumeración
  @{text "diag_arbolb :"} $\mathbb{N}\to arbolb$ del tipo de dato 
  @{text "arbolb"}.

  Dado $n\in \mathbb{N}$, supogamos que $diag(n) = (x,y)$.
  \begin{enumerate}
    \qtreecenterfalse
    \item Si $x=0$ entonces @{text "diag_arbolb(n)"} es el árbol
      \begin{center}
         \Tree [[.$y$ ]] 
      \end{center}
    \item Si $x=z+1$ para algún $z\in \mathbb{N}$ entonces, @{text
      "diag_arbolb(n)"} es el árbol         
       \begin{center}
         \qtreecenterfalse
        \Tree [ \qroof{@{text "diag_arbolb(z)"}}.{\textbullet}  
                \qroof{@{text "diag_arbolb(y)"}}.{\textbullet}  ]
        \end{center}                
    \end{enumerate}
\<close>

function diag_arbolb :: "nat \<Rightarrow> arbolb" where
"diag_arbolb n = (case fst (diag n) of
       0 \<Rightarrow> Hoja (snd (diag n))
      | Suc z \<Rightarrow> Arbol (diag_arbolb z) (diag_arbolb (snd (diag n))))"
by auto

(*<*)
text \<open> 
  Los siguientes lemas permiten demostrar la terminación de la funcion
  {\em diag-arbolb}. 
\<close>
(*>*)

(*<*)
lemma diag_le1: "fst (diag (Suc n)) < Suc n"
by (induct n) (simp_all add: Let_def split_def split: nat.split) 

lemma diag_le2: "snd (diag (Suc (Suc n))) < Suc (Suc n)"
using diag_le1 by (induct n) (simp_all add: Let_def split_def split: nat.split) 

lemma diag_le3:
  assumes "fst (diag n) = Suc x"
  shows "snd (diag n) < n"
proof (cases n) 
  assume "n=0" thus "snd (diag n) < n" using assms by simp
next
  fix nat
  assume h1: "n = Suc nat"
  show "snd (diag n) < n"
  proof (cases nat)
    assume "nat = 0"
    thus "snd (diag n) < n" using assms h1 by (simp add: Let_def)
  next 
    fix nata
    assume "nat = Suc nata"
    thus "snd (diag n) < n" using assms h1 by hypsubst (rule diag_le2)
  qed
qed

lemma diag_le4: 
  assumes "fst (diag n) = Suc x"
  shows "x < n"
proof (cases n)  
  assume "n = 0" thus "x < n" using assms by simp
next
  fix nat
  assume h1: "n = Suc nat" 
  show "x < n"
  proof (cases nat)
    assume "nat = 0" thus "x < n" using assms h1 by hypsubst (simp add: Let_def)
  next
    fix nata
    assume h2: "nat = Suc nata"
    hence "fst(diag n) = fst(diag (Suc(Suc nata)))" using h1 by simp
    hence "fst(diag (Suc(Suc nata))) = Suc x" using assms by simp
    moreover
    have "fst(diag (Suc(Suc nata))) < Suc(Suc nata)" by (rule diag_le1)
    ultimately
    have "Suc x < Suc (Suc nata)" by simp
    thus "x < n" using h1 h2 by simp
  qed
qed

termination diag_arbolb
by (relation "measure (\<lambda>x. x)") (auto intro: diag_le3 diag_le4)
(*>*)

text \<open> 
  La siguiente función {\em undiag-arbolb} corresponde a una inversa
  (por derecha) de la función {\em diag-arbolb}.
\<close> 

primrec undiag_arbolb :: "arbolb \<Rightarrow> nat" where
  "undiag_arbolb (Hoja n) = undiag (0, n)"
| "undiag_arbolb (Arbol t1 t2) =
   undiag (Suc (undiag_arbolb t1), undiag_arbolb t2)"

text \<open> 
  El siguiente lema demuestra que {\em undiag-arbolb} es inversa por
  derecha de \linebreak 
  {\em diag-arbolb}.
\<close>

lemma diag_undiag_arbolb [simp]: "diag_arbolb (undiag_arbolb t) = t"
by (induct t) (simp_all add: Let_def)

text \<open> 
  Por consiguiente, la función  @{text "diag_arbolb"} es una enumeración
  del tipo de dato @{text "arbolb"}: 
\<close>

lemma enumeration_arbolb: "enumeration (diag_arbolb :: nat \<Rightarrow> arbolb)"
proof - 
  have "\<forall>x. diag_arbolb (undiag_arbolb x) = x" 
    using diag_undiag_arbolb by blast
  hence "\<exists>undiag_arbolb. \<forall>x . diag_arbolb (undiag_arbolb x) = x" by blast
  thus ?thesis using enumeration[of diag_arbolb] by auto
qed

(*<*)
declare diag_arbolb.simps [simp del] undiag_arbolb.simps [simp del]
(*>*)

(*<*)
end
(*>*)
