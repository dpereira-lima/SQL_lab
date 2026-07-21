with base as
(
select
    decode(cua.nr_sequencia, 9, 'Onco Clínica', cua.ds_classif) ds_clinica,
	trunc(avg(nullif(to_number(obter_diferen_dt(a.dt_historico, a.dt_fim_historico, 'TM')), 0))) qt_avg_min_proces_alta,
	trunc(avg(nullif(to_number(obter_diferen_dt(obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'I', 'I','N'), obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'F', 'I','N'), 'TM')), 0))) qt_avg_min_interd,
	trunc(avg(nullif(to_number(obter_diferen_dt(obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'I', 'S','N'), obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'F', 'S','N'), 'TM')), 0))) qt_avg_min_saida_interd,
	trunc(avg(nullif(to_number(obter_diferen_dt(obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'I', 'G','N'), obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'F', 'G','N'), 'TM')), 0))) qt_avg_min_ag_higi,
	trunc(avg(nullif(to_number(obter_diferen_dt(obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'I', 'H','N'), obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'F', 'H','N'), 'TM')), 0))) qt_avg_min_em_higi,
	trunc(avg(nullif(to_number(obter_diferen_dt(obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'I', 'R','N'), obter_datas_status_leito(a.nr_seq_unidade, a.nr_sequencia, 'F', 'R','N'), 'TM')), 0))) qt_avg_min_res
from unidade_atend b
    inner join setor_atend sa
        on b.cd_setor_atend = sa.cd_setor_atend
        and upper(sa.ds_setor_atend) not like '%PS%'
        and upper(sa.ds_setor_atend) not like '%RADIOL%'
        and upper(sa.ds_setor_atend) not like '%HOSP%'
        and upper(sa.ds_setor_atend) not like '%CIRUR%'
    inner join un_atend_hist a
        on b.nr_seq_interno = a.nr_seq_unidade
        and a.ie_status_unidade = 'A'
        and trunc(a.dt_historico) between trunc(sysdate - 90) and trunc(sysdate -1)
    left join base_status vl
        on b.ie_status_unidade = vl.ie_base_status
    left join base_classif_setor vl_2
        on sa.cd_classif_setor = vl_2.cd_base_classif_setor
    left join classif_un_atend cua
        on b.nr_seq_classif = cua.nr_sequencia
where b.ie_situacao = 'A'
group by decode(cua.nr_sequencia, 9, 'Onco Clínica', cua.ds_classificacao)
)
select 
    ds_clinica,
    'Em Processo de Alta' ds_status,
    qt_avg_min_proces_alta qt_min_status
from base
union all
select 
    ds_clinica,
    'Interditado' ds_status,
    qt_avg_min_interd qt_min_status
from base
union all
select 
    ds_clinica,
    'Saída de interdição' ds_status,
    qt_avg_min_saida_interd qt_min_status
from base
union all
select 
    ds_clinica,
    'Aguardando higienização' ds_status,
    qt_avg_min_ag_higi qt_min_status
from base
union all
select 
    ds_clinica,
    'Em Higienização' ds_status,
    qt_avg_min_em_higi qt_min_status
from base
union all
select 
    ds_clinica,
    'Reservado' ds_status,
    qt_avg_min_res qt_min_status
from base
;