<%-- 
    Document   : minhas_aulas
    Created on : 13/01/2026, 11:54:18
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Aluno".equals(tipo)) { response.sendRedirect("login.jsp"); return; }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Agendar Aula - Drive School</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family: 'Work Sans', sans-serif;
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
            background-attachment: fixed;
            color: white; min-height: 100vh;
        }

        /* TOPBAR */
        .topbar {
            background: rgba(0,0,0,0.4); backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255,193,7,0.2);
            padding: 12px 30px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .topbar-left { display: flex; align-items: center; gap: 18px; }
        .topbar-left img { height: 46px; filter: drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display: flex; align-items: center; gap: 8px; font-size: .9rem; }
        .user-info i { color: #FFC107; }
        .btn-sair {
            background: rgba(255,255,255,.1); color: white; padding: 8px 20px;
            border-radius: 25px; text-decoration: none; font-weight: 600;
            border: 2px solid rgba(255,255,255,.3); display: inline-flex;
            align-items: center; gap: 7px; transition: all .3s; font-size: .9rem;
        }
        .btn-sair:hover { border-color: #FFC107; color: #FFC107; }

        /* LAYOUT */
        .page-wrap { max-width: 900px; margin: 0 auto; padding: 35px 20px; }
        .page-header { text-align: center; margin-bottom: 30px; }
        .page-header h1 { font-size: 1.9rem; font-weight: 800; }
        .page-header h1 i { color: #FFC107; margin-right: 10px; }
        .page-header p { color: rgba(255,255,255,.65); margin-top: 6px; }

        /* CARDS */
        .card {
            background: rgba(255,255,255,.05); backdrop-filter: blur(10px);
            border: 1px solid rgba(255,193,7,.2); border-radius: 18px; padding: 30px;
            margin-bottom: 22px;
        }
        .card-title {
            font-size: .8rem; text-transform: uppercase; letter-spacing: 1px;
            color: #FFC107; font-weight: 700; margin-bottom: 18px;
            display: flex; align-items: center; gap: 8px;
        }
        .card-title::after { content:''; flex:1; height:1px; background: rgba(255,193,7,.2); }

        /* INSTRUTOR BOX */
        .instrutor-box {
            display: flex; align-items: center; gap: 14px;
        }
        .instrutor-avatar {
            width: 50px; height: 50px; border-radius: 14px;
            background: rgba(255,193,7,.2); border: 1px solid rgba(255,193,7,.35);
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .instrutor-avatar i { color: #FFC107; font-size: 1.4rem; }
        .instrutor-nome { font-size: 1.1rem; font-weight: 700; }
        .instrutor-sub { font-size: .85rem; color: rgba(255,255,255,.6); margin-top: 2px; }

        /* CALENDÁRIO DE HORÁRIOS */
        .horarios-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 16px; flex-wrap: wrap; gap: 10px;
        }
        .data-selecionada-label { font-size: .85rem; color: rgba(255,255,255,.6); }
        .data-selecionada-label span { color: #FFC107; font-weight: 700; }

        .legenda { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 18px; }
        .legenda-item { display: flex; align-items: center; gap: 7px; font-size: .82rem; color: rgba(255,255,255,.7); }
        .legenda-dot { width: 14px; height: 14px; border-radius: 4px; flex-shrink: 0; }
        .dot-livre    { background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.25); }
        .dot-ocupado  { background: rgba(220,53,69,.35); border: 1px solid rgba(220,53,69,.6); }
        .dot-sel      { background: rgba(255,193,7,.4); border: 1px solid #FFC107; }

        .horarios-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(90px, 1fr)); gap: 10px;
        }
        .slot {
            padding: 12px 8px; border-radius: 10px; text-align: center;
            font-size: .9rem; font-weight: 600; cursor: pointer; transition: all .25s;
            border: 1px solid transparent; user-select: none;
        }
        .slot-livre {
            background: rgba(255,255,255,.08); border-color: rgba(255,255,255,.2);
            color: white;
        }
        .slot-livre:hover {
            background: rgba(255,193,7,.2); border-color: #FFC107; color: #FFC107;
            transform: translateY(-2px);
        }
        .slot-ocupado {
            background: rgba(220,53,69,.25); border-color: rgba(220,53,69,.5);
            color: rgba(255,100,100,.8); cursor: not-allowed;
            position: relative;
        }
        .slot-ocupado::after {
            content: '\f023'; font-family: 'Font Awesome 5 Free'; font-weight: 900;
            font-size: .65rem; display: block; margin-top: 3px; opacity: .7;
        }
        .slot-selecionado {
            background: rgba(255,193,7,.3); border-color: #FFC107;
            color: #FFC107; transform: translateY(-2px);
            box-shadow: 0 4px 14px rgba(255,193,7,.25);
        }
        .slot-indisponivel {
            background: rgba(255,255,255,.03); border-color: rgba(255,255,255,.08);
            color: rgba(255,255,255,.2); cursor: not-allowed;
        }

        /* FORM */
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block; margin-bottom: 8px; font-weight: 600;
            color: rgba(255,255,255,.85); font-size: .9rem;
        }
        .form-group label i { color: #FFC107; margin-right: 6px; }
        .form-group input, .form-group select {
            width: 100%; padding: 13px 15px; border-radius: 10px;
            border: 1px solid rgba(255,255,255,.2);
            background: rgba(255,255,255,.08); color: white;
            font-size: .95rem; font-family: 'Work Sans', sans-serif; transition: all .3s;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none; border-color: #FFC107;
            background: rgba(255,255,255,.12);
            box-shadow: 0 0 0 3px rgba(255,193,7,.15);
        }
        .form-group select option { background: #1a3a4d; }

        /* RESUMO SELEÇÃO */
        .resumo-sel {
            background: rgba(255,193,7,.1); border: 1px solid rgba(255,193,7,.3);
            border-radius: 12px; padding: 16px 20px; margin-bottom: 20px;
            display: none;
        }
        .resumo-sel.visivel { display: block; }
        .resumo-sel p { font-size: .9rem; color: rgba(255,255,255,.85); line-height: 1.8; }
        .resumo-sel strong { color: #FFC107; }

        /* ALERTS */
        .alert {
            padding: 14px 18px; border-radius: 12px; margin-bottom: 22px;
            display: flex; align-items: flex-start; gap: 12px; font-size: .9rem;
        }
        .alert i { font-size: 1.1rem; flex-shrink: 0; margin-top: 1px; }
        .alert-error { background: rgba(220,53,69,.2); border: 1px solid rgba(220,53,69,.5); color: #f5a0a8; }
        .alert-info  { background: rgba(33,150,243,.15); border: 1px solid rgba(33,150,243,.4); color: #90caf9; }

        /* BOTÕES */
        .btn-group { display: flex; gap: 12px; margin-top: 10px; }
        .btn {
            padding: 13px 28px; border-radius: 25px; font-size: .95rem; font-weight: 700;
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
            transition: all .3s; border: none; cursor: pointer; font-family: 'Work Sans', sans-serif;
            flex: 1; justify-content: center;
        }
        .btn-primary { background: linear-gradient(135deg,#FFC107,#FFB300); color: #1a3a4d; box-shadow: 0 5px 18px rgba(255,193,7,.35); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(255,193,7,.55); }
        .btn-primary:disabled { opacity: .5; cursor: not-allowed; transform: none; }
        .btn-secondary { background: rgba(255,255,255,.1); color: white; border: 2px solid rgba(255,255,255,.25); }
        .btn-secondary:hover { background: rgba(255,255,255,.18); }

        @media(max-width:600px) {
            .horarios-grid { grid-template-columns: repeat(3,1fr); }
            .btn-group { flex-direction: column; }
        }
    </style>
</head>
<body>

    <!-- TOPBAR -->
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard_aluno.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info">
                <i class="fa fa-user-graduate"></i>
                <span><strong><%= username %></strong> (Aluno)</span>
            </div>
        </div>
        <div style="display:flex;gap:10px;align-items:center;">
            <a href="dashboard_aluno.jsp" style="background:rgba(255,255,255,.1);color:white;padding:9px 20px;border-radius:25px;text-decoration:none;font-weight:600;border:2px solid rgba(255,255,255,.3);display:inline-flex;align-items:center;gap:7px;transition:all .3s;" onmouseover="this.style.borderColor='#FFC107';this.style.color='#FFC107'" onmouseout="this.style.borderColor='rgba(255,255,255,.3)';this.style.color='white'">
                <i class="fa fa-arrow-left"></i>Voltar
            </a>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>Sair
            </a>
        </div>
    </div>

    <div class="page-wrap">
        <div class="page-header">
            <h1><i class="fa fa-calendar-plus"></i>Agendar Nova Aula</h1>
            <p>Escolhe a data e o horário disponível com o teu instrutor</p>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            Integer idAluno = null;
            Integer idInstrutor = null;
            String nomeInstrutor = "";
            String erro = request.getParameter("erro");

            Calendar hoje = Calendar.getInstance();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String dataMin = sdf.format(hoje.getTime());
            hoje.add(Calendar.DAY_OF_MONTH, 30);
            String dataMax = sdf.format(hoje.getTime());

            // Horas disponíveis
            String[] todasHoras = {"08:00","09:00","10:00","11:00","12:00","14:00","15:00","16:00","17:00","18:00"};

            // Declarar fora do try para serem visíveis no HTML
            int acessoConducao = 0, aprovadoCodigo = 0, totalConducao = 0, limiteConducao = 15;

            // Buscar aulas ocupadas do instrutor para os próximos 30 dias
            // Guardar como Map<data, List<hora>>
            Map<String, List<String>> aulasMarcadas = new LinkedHashMap<>();

            try {
                conn = ConexaoBD.getConnection();

                // Buscar dados do aluno
                pstmt = conn.prepareStatement(
                    "SELECT u.idAluno as id, a.idInstrutor, i.nome as nomeInstrutor " +
                    "FROM t_utilizador u " +
                    "LEFT JOIN aluno a ON u.idAluno = a.id " +
                    "LEFT JOIN instrutor i ON a.idInstrutor = i.id " +
                    "WHERE u.username = ?");
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    idAluno = rs.getInt("id");
                    idInstrutor = rs.getInt("idInstrutor");
                    nomeInstrutor = rs.getString("nomeInstrutor");
                }
                rs.close(); pstmt.close();

                // Verificar acesso à condução e limites
                if (idAluno != null) {
                    pstmt = conn.prepareStatement(
                        "SELECT acessoConducao, aprovadoCodigo FROM aluno WHERE id=?");
                    pstmt.setInt(1, idAluno);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        acessoConducao = rs.getInt("acessoConducao");
                        aprovadoCodigo = rs.getInt("aprovadoCodigo");
                    }
                    rs.close(); pstmt.close();

                    pstmt = conn.prepareStatement(
                        "SELECT COUNT(*) as total FROM aula_conducao WHERE idAluno=? AND estado != 'cancelada'");
                    pstmt.setInt(1, idAluno);
                    rs = pstmt.executeQuery();
                    if (rs.next()) totalConducao = rs.getInt("total");
                    rs.close(); pstmt.close();
                }
                limiteConducao = aprovadoCodigo == 1 ? 30 : 15;

                // Buscar aulas já marcadas do instrutor (sem expor nome do aluno)
                if (idInstrutor != null && idInstrutor > 0) {
                    pstmt = conn.prepareStatement(
                        "SELECT DATE_FORMAT(dataHoraInicio,'%Y-%m-%d') as dia, " +
                        "DATE_FORMAT(dataHoraInicio,'%H:%i') as hora, " +
                        "TIMESTAMPDIFF(HOUR, dataHoraInicio, dataHoraFim) as duracao " +
                        "FROM aula_conducao " +
                        "WHERE idInstrutor = ? " +
                        "AND dataHoraInicio >= NOW() " +
                        "AND estado != 'cancelada'");
                    pstmt.setInt(1, idInstrutor);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        String dia = rs.getString("dia");
                        String hora = rs.getString("hora");
                        int dur = rs.getInt("duracao");
                        if (!aulasMarcadas.containsKey(dia)) aulasMarcadas.put(dia, new ArrayList<>());
                        aulasMarcadas.get(dia).add(hora);
                        // Se duração 2h, bloquear também a hora seguinte
                        if (dur >= 2) {
                            // Calcular hora+1
                            String[] partes = hora.split(":");
                            int h = Integer.parseInt(partes[0]) + 1;
                            String horaPlus = String.format("%02d:00", h);
                            aulasMarcadas.get(dia).add(horaPlus);
                        }
                    }
                    rs.close(); pstmt.close();
                }

            } catch (Exception e) {
                out.println("<div class='alert alert-error'><i class='fa fa-exclamation-circle'></i>Erro: " + e.getMessage() + "</div>");
            } finally {
                try { if (conn != null) conn.close(); } catch(Exception e){}
            }
        %>

        <% if (erro != null) { %>
            <div class="alert alert-error">
                <i class="fa fa-exclamation-triangle"></i>
                <div>
                    <% if ("limite".equals(erro)) { %>Já tens 2 horas agendadas para esse dia! Limite diário atingido.
                    <% } else if ("conflito".equals(erro)) { %>O instrutor já tem uma aula nesse horário! Escolhe outro horário.
                    <% } else if ("passado".equals(erro)) { %>Não podes agendar aulas no passado!
                    <% } else if ("semveiculo".equals(erro)) { %>Não há veículos disponíveis! Contacta a escola.
                    <% } else { %>Erro ao processar o agendamento. Tenta novamente.
                    <% } %>
                </div>
            </div>
        <% } %>

        <% if (idAluno == null) { %>
            <div class="alert alert-error"><i class="fa fa-exclamation-circle"></i>Aluno não encontrado.</div>
        <% } else if (idInstrutor == null || idInstrutor == 0) { %>
            <div class="alert alert-error"><i class="fa fa-exclamation-circle"></i>Não tens instrutor atribuído. Contacta a escola.</div>
        <% } else if (acessoConducao == 0) { %>
            <div class="card" style="text-align:center;padding:50px 30px;">
                <div style="font-size:3.5rem;margin-bottom:20px;">🔒</div>
                <h2 style="font-size:1.5rem;margin-bottom:12px;">Acesso às aulas de condução bloqueado</h2>
                <p style="color:rgba(255,255,255,.65);max-width:420px;margin:0 auto 24px;line-height:1.7;">
                    Para poderes agendar aulas de condução precisas de completar as
                    <strong style="color:#FFC107">20 aulas teóricas de código</strong>.<br>
                    Quando estiveres pronto, o administrador ativa o teu acesso.
                </p>
                <a href="dashboard_aluno.jsp" class="btn btn-secondary" style="display:inline-flex;justify-content:center;max-width:200px;margin:0 auto;">
                    <i class="fa fa-arrow-left"></i>Voltar
                </a>
            </div>
        <% } else if (totalConducao >= limiteConducao) { %>
            <div class="card" style="text-align:center;padding:50px 30px;">
                <div style="font-size:3.5rem;margin-bottom:20px;">⚠️</div>
                <h2 style="font-size:1.5rem;margin-bottom:12px;">Limite de aulas atingido</h2>
                <% if (aprovadoCodigo == 0) { %>
                <p style="color:rgba(255,255,255,.65);max-width:420px;margin:0 auto 24px;line-height:1.7;">
                    Já fizeste <strong style="color:#FFC107"><%= totalConducao %> aulas de condução</strong>.
                    Para continuares precisas de <strong style="color:#FFC107">passar no exame de código</strong>.
                    Após aprovação poderás fazer mais 15 aulas (total 30).
                </p>
                <% } else { %>
                <p style="color:rgba(255,255,255,.65);max-width:420px;margin:0 auto 24px;line-height:1.7;">
                    Já atingiste o limite de <strong style="color:#FFC107">30 aulas de condução</strong>.
                    Se precisares de mais aulas, contacta a escola para acordo adicional.
                </p>
                <% } %>
                <a href="dashboard_aluno.jsp" class="btn btn-secondary" style="display:inline-flex;justify-content:center;max-width:200px;margin:0 auto;">
                    <i class="fa fa-arrow-left"></i>Voltar
                </a>
            </div>
        <% } else { %>

            <!-- INSTRUTOR -->
            <div class="card">
                <div class="card-title"><i class="fa fa-user-tie"></i> O teu instrutor</div>
                <div class="instrutor-box">
                    <div class="instrutor-avatar"><i class="fa fa-user-tie"></i></div>
                    <div>
                        <div class="instrutor-nome"><%= nomeInstrutor %></div>
                        <div class="instrutor-sub">Instrutor atribuído à tua conta</div>
                    </div>
                </div>
            </div>

            <!-- FORMULÁRIO -->
            <div class="card">
                <div class="card-title"><i class="fa fa-calendar-alt"></i> Escolhe a data</div>

                <div class="alert alert-info">
                    <i class="fa fa-info-circle"></i>
                    <div>
                        <strong>Regras:</strong> Máximo 2 horas por dia &nbsp;•&nbsp;
                        Horário: 08h–18h &nbsp;•&nbsp;
                        Os horários a <span style="color:#ff6b6b;font-weight:700">vermelho</span> já estão ocupados
                    </div>
                </div>

                <form action="processar_agendamento.jsp" method="POST" id="formAgendar">
                    <input type="hidden" name="idAluno" value="<%= idAluno %>">
                    <input type="hidden" name="idInstrutor" value="<%= idInstrutor %>">
                    <input type="hidden" name="hora" id="horaHidden">
                    <input type="hidden" name="duracao" id="duracaoHidden">

                    <!-- DATA -->
                    <div class="form-group">
                        <label><i class="fa fa-calendar"></i> Data da Aula</label>
                        <input type="date" name="data" id="dataInput"
                               min="<%= dataMin %>" max="<%= dataMax %>"
                               onchange="atualizarHorarios(this.value)" required>
                    </div>

                    <!-- DURAÇÃO -->
                    <div class="form-group">
                        <label><i class="fa fa-hourglass-half"></i> Duração</label>
                        <select name="duracaoSelect" id="duracaoSelect" onchange="atualizarHorarios(document.getElementById('dataInput').value)">
                            <option value="1">1 hora</option>
                            <option value="2">2 horas</option>
                        </select>
                    </div>

                    <!-- HORÁRIOS -->
                    <div id="horariosSection" style="display:none;">
                        <div class="card-title" style="margin-bottom:12px;">
                            <i class="fa fa-clock"></i> Horários disponíveis
                        </div>

                        <div class="legenda">
                            <div class="legenda-item"><div class="legenda-dot dot-livre"></div> Disponível</div>
                            <div class="legenda-item"><div class="legenda-dot dot-ocupado"></div> Ocupado</div>
                            <div class="legenda-item"><div class="legenda-dot dot-sel"></div> Selecionado</div>
                        </div>

                        <div class="horarios-grid" id="horariosGrid"></div>
                    </div>

                    <!-- RESUMO -->
                    <div class="resumo-sel" id="resumoSel">
                        <p>
                            <i class="fa fa-check-circle" style="color:#FFC107"></i>&nbsp;
                            <strong>Data:</strong> <span id="resumoData"></span> &nbsp;•&nbsp;
                            <strong>Hora:</strong> <span id="resumoHora"></span> &nbsp;•&nbsp;
                            <strong>Duração:</strong> <span id="resumoDuracao"></span>
                        </p>
                    </div>

                    <div class="btn-group">
                        <a href="minhas_aulas_aluno.jsp" class="btn btn-secondary">
                            <i class="fa fa-arrow-left"></i>Cancelar
                        </a>
                        <button type="submit" class="btn btn-primary" id="btnConfirmar" disabled>
                            <i class="fa fa-check"></i>Confirmar Agendamento
                        </button>
                    </div>
                </form>
            </div>

        <% } %>
    </div>

    <script>
        // Mapa de aulas ocupadas vindo do servidor
        const aulasMarcadas = {
            <%
                boolean primeiro = true;
                for (Map.Entry<String, List<String>> entry : aulasMarcadas.entrySet()) {
                    if (!primeiro) out.print(",");
                    out.print("\"" + entry.getKey() + "\": [");
                    boolean p2 = true;
                    for (String h : entry.getValue()) {
                        if (!p2) out.print(",");
                        out.print("\"" + h + "\"");
                        p2 = false;
                    }
                    out.print("]");
                    primeiro = false;
                }
            %>
        };

        const todasHoras = ["08:00","09:00","10:00","11:00","12:00","14:00","15:00","16:00","17:00","18:00"];
        let horaSelecionada = null;

        function atualizarHorarios(data) {
            if (!data) return;
            horaSelecionada = null;
            document.getElementById('horaHidden').value = '';
            document.getElementById('btnConfirmar').disabled = true;
            document.getElementById('resumoSel').classList.remove('visivel');

            const duracao = parseInt(document.getElementById('duracaoSelect').value);
            const ocupadas = aulasMarcadas[data] || [];
            const grid = document.getElementById('horariosGrid');
            grid.innerHTML = '';

            todasHoras.forEach(hora => {
                const div = document.createElement('div');
                div.className = 'slot';
                div.textContent = hora;

                // Verificar se este slot ou algum necessário para a duração está ocupado
                const hNum = parseInt(hora.split(':')[0]);
                let bloqueado = ocupadas.includes(hora);

                // Para duração 2h, verificar se a próxima hora também está livre
                if (!bloqueado && duracao === 2) {
                    const horaPlus = String(hNum + 1).padStart(2,'0') + ':00';
                    if (ocupadas.includes(horaPlus)) bloqueado = true;
                    // Última hora não permite 2h
                    if (hNum >= 18) bloqueado = true;
                }

                if (bloqueado) {
                    div.classList.add('slot-ocupado');
                    div.title = 'Horário já ocupado';
                } else {
                    div.classList.add('slot-livre');
                    div.onclick = () => selecionarHora(hora, div, data, duracao);
                }

                grid.appendChild(div);
            });

            document.getElementById('horariosSection').style.display = 'block';
        }

        function selecionarHora(hora, el, data, duracao) {
            // Limpar seleção anterior
            document.querySelectorAll('.slot-selecionado').forEach(s => {
                s.classList.remove('slot-selecionado');
                s.classList.add('slot-livre');
            });

            el.classList.remove('slot-livre');
            el.classList.add('slot-selecionado');
            horaSelecionada = hora;

            document.getElementById('horaHidden').value = hora;
            document.getElementById('duracaoHidden').value = duracao;
            document.getElementById('btnConfirmar').disabled = false;

            // Atualizar resumo
            const dataFormatada = new Date(data + 'T00:00:00').toLocaleDateString('pt-PT', {weekday:'long', day:'2-digit', month:'long', year:'numeric'});
            document.getElementById('resumoData').textContent = dataFormatada;
            document.getElementById('resumoHora').textContent = hora;
            document.getElementById('resumoDuracao').textContent = duracao + ' hora' + (duracao > 1 ? 's' : '');
            document.getElementById('resumoSel').classList.add('visivel');
        }

        document.getElementById('formAgendar').onsubmit = function(e) {
            if (!horaSelecionada) {
                e.preventDefault();
                alert('Por favor seleciona um horário!');
            }
        };
    </script>
</body>
</html>

