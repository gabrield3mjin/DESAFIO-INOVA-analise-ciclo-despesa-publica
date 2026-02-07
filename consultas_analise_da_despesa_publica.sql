--1. Existem contratos sem empenhos?
SELECT
    c.id_contrato
FROM contrato c
LEFT JOIN empenho e
    ON c.id_contrato = e.id_contrato
WHERE e.id_empenho IS NULL;

--2. Existem contratos com empenhos acima do valor contratado? Se sim, qual é o valor excedente?
WITH total_empenhado_por_contrato AS (
    SELECT
        c.id_contrato,
        c.valor AS valor_contrato,
        SUM(e.valor) AS total_empenhado
    FROM contrato c
    JOIN empenho e
        ON e.id_contrato = c.id_contrato
    GROUP BY
        c.id_contrato,
        c.valor
)
SELECT
    id_contrato,
    valor_contrato,
    total_empenhado,
    (total_empenhado - valor_contrato) AS valor_excedente
FROM total_empenhado_por_contrato
WHERE total_empenhado > valor_contrato
ORDER BY valor_excedente DESC;

--3. Existem contratos sem entidade/fornecedor associados?
SELECT
    id_contrato
FROM contrato
WHERE id_entidade IS NULL;

SELECT
    id_contrato
FROM contrato
WHERE id_fornecedor IS NULL;

--4. Existem empenhos que não foram liquidados?
SELECT
    e.id_empenho
FROM empenho e
LEFT JOIN liquidacao_nota_fiscal l
    ON e.id_empenho = l.id_empenho
WHERE l.id_liquidacao_empenhonotafiscal IS NULL;

--5. Existem empenhos com liquidação acima do valor empenhado?
SELECT
    e.id_empenho,
    e.valor AS valor_empenhado,
    SUM(l.valor) AS total_liquidado
FROM empenho e
JOIN liquidacao_nota_fiscal l
    ON e.id_empenho = l.id_empenho
GROUP BY e.id_empenho, e.valor
HAVING SUM(l.valor) > e.valor;

--6. Existem empenhos sem pagamento?
SELECT
    e.id_empenho
FROM empenho e
LEFT JOIN pagamento p
    ON e.id_empenho = p.id_empenho
WHERE p.id_pagamento IS NULL;

--7. Existem empenhos pagos acima do valor empenhado?
SELECT
    e.id_empenho,
    e.valor AS valor_empenhado,
    SUM(p.valor) AS total_pago
FROM empenho e
JOIN pagamento p
    ON e.id_empenho = p.id_empenho
GROUP BY e.id_empenho, e.valor
HAVING SUM(p.valor) > e.valor;

--8. Existem NF-e que constam na base, mas nunca passaram pelo processo de liquidação?
SELECT
    n.chave_nfe,
    n.numero_nfe,
    n.data_hora_emissao,
    n.valor_total_nfe
FROM nfe n
LEFT JOIN liquidacao_nota_fiscal l
    ON n.chave_nfe = l.chave_danfe
WHERE l.id_liquidacao_empenhonotafiscal IS NULL;

--9. Existe NF-e sem pagamento associado?
NF-e sem pagamento associado
SELECT
    n.chave_nfe
FROM nfe n
LEFT JOIN nfe_pagamento np
    ON n.chave_nfe = np.chave_nfe
WHERE np.id IS NULL;

--10. Existe NF-e com pagamento acima do valor em nota?
SELECT
    n.chave_nfe,
    n.valor_total_nfe,
    SUM(np.valor_pagamento) AS total_pago_nfe
FROM nfe n
JOIN nfe_pagamento np
    ON n.chave_nfe = np.chave_nfe
GROUP BY n.chave_nfe, n.valor_total_nfe
HAVING SUM(np.valor_pagamento) > n.valor_total_nfe;

--11. Existem pagamentos sem liquidação correspondente?
SELECT
    p.id_pagamento,
    p.id_empenho,
    p.valor
FROM pagamento p
LEFT JOIN liquidacao_nota_fiscal l
    ON p.id_empenho = l.id_empenho
WHERE l.id_liq_empnf IS NULL;