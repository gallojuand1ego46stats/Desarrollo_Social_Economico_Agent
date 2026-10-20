# Modulo 3. Implementacion numerica independiente de R/07.
#
# Diferencias deliberadas frente al calculo principal:
#   - Pearson se reconstruye con centrado y productos cruzados, sin cor().
#   - La inversa se obtiene con solve(), sin chol() ni chol2inv().
#   - El log-determinante usa descomposicion LU, sin reutilizar Cholesky.
#   - La cola de Bartlett usa una suma finita logaritmica, sin pchisq().
# No se leen resultados de referencia dentro de este modulo.

#' Reconstruir Pearson a partir de las observaciones originales.
#' @return Matriz simetrica de correlaciones, con nombres de las candidatas.
vk_pearson <- function(X) {
  n <- nrow(X)
  centrada <- sweep(X, 2L, colSums(X) / n, FUN = "-")
  desviaciones <- sqrt(colSums(centrada^2) / (n - 1L))
  Z <- sweep(centrada, 2L, desviaciones, FUN = "/")
  crossprod(Z) / (n - 1L)
}

#' Logaritmo natural de la supervivencia chi-cuadrado con gl pares positivos.
#' Para gl=2m: P(Chi2 > x)=exp(-x/2)*sum((x/2)^j/j!, j=0,...,m-1).
#' La suma se evalua con log-sum-exp para evitar subdesbordamiento numerico.
#' Esta identidad es especifica de gl pares; se rechaza otro caso explicitamente.
vk_log_cola_chi_par <- function(x, gl) {
  vk_exigir(length(x) == 1L && is.finite(x) && x >= 0,
            "El estadistico chi-cuadrado debe ser un escalar finito no negativo.")
  vk_exigir(length(gl) == 1L && is.finite(gl) && gl > 0 && gl %% 2 == 0,
            "La cola independiente requiere grados de libertad pares positivos.")
  if (x == 0) return(0)  # log(1): caso limite de la distribucion central.
  j <- seq.int(0L, as.integer(gl / 2L) - 1L)
  terminos <- j * log(x / 2) - lgamma(j + 1)
  maximo <- max(terminos)
  -x / 2 + maximo + log(sum(exp(terminos - maximo)))
}

#' Calcular KMO global, ocho MSA y Bartlett desde X, sin cifras de referencia.
#' @return Lista de resultados y diagnosticos de estabilidad numerica.
vk_calcular <- function(X, config) {
  n <- nrow(X)
  p <- ncol(X)
  R <- vk_pearson(X)
  tol <- config$tolerancia
  vk_exigir(max(abs(R - t(R))) <= tol[["estructura"]], "Pearson no resulta simetrica.")
  vk_exigir(max(abs(diag(R) - 1)) <= tol[["estructura"]], "La diagonal de Pearson difiere de uno.")

  # Los autovalores solo comprueban definicion positiva: no se interpreta PCA.
  autovalores <- eigen(R, symmetric = TRUE, only.values = TRUE)$values
  vk_exigir(all(is.finite(autovalores) & autovalores > 0),
            "La matriz no es definida positiva; no se usara pseudoinversa o regularizacion.")
  inversa <- solve(R, diag(p))
  residuo <- max(abs(R %*% inversa - diag(p)))
  vk_exigir(residuo <= tol[["residuo_inversa"]], "El residuo de la inversa supera la tolerancia.")
  vk_exigir(all(diag(inversa) > 0), "La inversa tiene elementos diagonales no positivos.")

  parciales <- -inversa / sqrt(outer(diag(inversa), diag(inversa)))
  r2 <- R^2
  a2 <- parciales^2
  diag(r2) <- 0
  diag(a2) <- 0  # Las sumas excluyen las autocorrelaciones.
  sumas_r2 <- rowSums(r2)
  sumas_a2 <- rowSums(a2)
  denominadores <- sumas_r2 + sumas_a2
  vk_exigir(all(denominadores > 0), "Existe un MSA con denominador nulo.")
  msa <- stats::setNames(sumas_r2 / denominadores, config$variables)
  kmo <- sum(r2) / (sum(r2) + sum(a2))

  determinante <- determinant(R, logarithm = TRUE)
  vk_exigir(determinante$sign == 1, "El determinante debe ser positivo.")
  logdet <- as.numeric(determinante$modulus)
  factor <- n - 1 - (2 * p + 5) / 6
  vk_exigir(factor > 0, "El tamano de la matriz no permite la correccion de Bartlett.")
  chi <- -factor * logdet
  gl <- p * (p - 1L) / 2L
  logp <- vk_log_cola_chi_par(chi, gl)
  vk_exigir(all(is.finite(c(kmo, msa, chi, logdet, logp))), "Hay resultados numericos no finitos.")
  vk_exigir(kmo >= 0 && kmo <= 1 && all(msa >= 0 & msa <= 1), "KMO o MSA fuera de [0,1].")

  # Se guarda una representacion cientifica textual de la cola diminuta.
  # exp(logp) puede ser cero en double: ese cero no es la probabilidad matematica.
  log10p <- logp / log(10)
  exponente <- floor(log10p)
  p_texto <- sprintf("%.6fe%d", 10^(log10p - exponente), as.integer(exponente))
  list(n = n, p = p, KMO = kmo, MSA = msa, chi_cuadrado = chi, gl = gl,
       ln_p_nominal = logp, log10_p_nominal = log10p, p_texto = p_texto,
       log_determinante = logdet, determinante = exp(logdet),
       suma_r2_pares = sum(r2) / 2, suma_parcial2_pares = sum(a2) / 2,
       condicion_2 = max(autovalores) / min(autovalores),
       minimo_autovalor_validacion = min(autovalores), residuo_inversa = residuo,
       correlaciones = R)
}
