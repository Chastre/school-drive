<%-- 
    Document   : dashboard_instrutor
    Created on : 18/12/2025, 01:06:40
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page import="java.text.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Instrutor".equals(tipo)) { response.sendRedirect("login.jsp"); return; }
    String username = (String) session.getAttribute("username");

    Integer idInstrutor = null;
    String nomeInstrutor = "";
    String veiculoInfo = "Sem veículo atribuído";
    int aulasDoDia = 0, totalAlunos = 0, aulasRealizadasTotal = 0, aulasAgendadasTotal = 0;
    String proximaAulaHoje = null;
    String nomeProximoAluno = null;

    // Saudação por hora
    Calendar cal = Calendar.getInstance();
    int hora = cal.get(Calendar.HOUR_OF_DAY);
    String saudacao = hora < 12 ? "Bom dia" : hora < 19 ? "Boa tarde" : "Boa noite";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = ConexaoBD.getConnection();

        // Dados do instrutor + veículo
        pstmt = conn.prepareStatement(
            "SELECT i.id, i.nome, v.marca, v.modelo, v.matricula " +
            "FROM instrutor i LEFT JOIN veiculo v ON i.idVeiculo = v.id " +
            "WHERE i.email = (SELECT email FROM t_utilizador WHERE username = ?)");
        pstmt.setString(1, username); rs = pstmt.executeQuery();
        if (rs.next()) {
            idInstrutor = rs.getInt("id");
            nomeInstrutor = rs.getString("nome");
            String marca = rs.getString("marca");
            String modelo = rs.getString("modelo");
            String matricula = rs.getString("matricula");
            if (marca != null) veiculoInfo = marca + " " + modelo + " (" + matricula + ")";
        }
        rs.close(); pstmt.close();

        if (idInstrutor != null) {
            // Aulas hoje
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM aula_conducao WHERE idInstrutor=? AND DATE(dataHoraInicio)=CURDATE() AND estado='Agendada'");
            pstmt.setInt(1, idInstrutor); rs = pstmt.executeQuery();
            if (rs.next()) aulasDoDia = rs.getInt(1);
            rs.close(); pstmt.close();

            // Total alunos
            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM aluno WHERE idInstrutor=?");
            pstmt.setInt(1, idInstrutor); rs = pstmt.executeQuery();
            if (rs.next()) totalAlunos = rs.getInt(1);
            rs.close(); pstmt.close();

            // Aulas realizadas total
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM aula_conducao WHERE idInstrutor=? AND estado='Concluída'");
            pstmt.setInt(1, idInstrutor); rs = pstmt.executeQuery();
            if (rs.next()) aulasRealizadasTotal = rs.getInt(1);
            rs.close(); pstmt.close();

            // Aulas agendadas futuras
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) FROM aula_conducao WHERE idInstrutor=? AND estado='Agendada' AND dataHoraInicio > NOW()");
            pstmt.setInt(1, idInstrutor); rs = pstmt.executeQuery();
            if (rs.next()) aulasAgendadasTotal = rs.getInt(1);
            rs.close(); pstmt.close();

            // Próxima aula de hoje
            pstmt = conn.prepareStatement(
                "SELECT TIME_FORMAT(dataHoraInicio,'%H:%i') as hora, a.nome as nomeAluno " +
                "FROM aula_conducao ac JOIN aluno a ON ac.idAluno = a.id " +
                "WHERE ac.idInstrutor=? AND DATE(ac.dataHoraInicio)=CURDATE() AND ac.estado='Agendada' AND ac.dataHoraInicio > NOW() " +
                "ORDER BY ac.dataHoraInicio ASC LIMIT 1");
            pstmt.setInt(1, idInstrutor); rs = pstmt.executeQuery();
            if (rs.next()) {
                proximaAulaHoje = rs.getString("hora");
                nomeProximoAluno = rs.getString("nomeAluno");
            }
            rs.close(); pstmt.close();
        }
    } catch(Exception e){ e.printStackTrace(); }
    finally { try{ if(rs!=null)rs.close(); if(pstmt!=null)pstmt.close(); if(conn!=null)conn.close(); }catch(SQLException e){ e.printStackTrace(); } }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Dashboard Instrutor - Drive School</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); background-attachment:fixed; color:white; min-height:100vh; }
        .topbar { background:rgba(0,0,0,0.4); backdrop-filter:blur(10px); padding:12px 30px; border-bottom:1px solid rgba(255,193,7,0.2); display:flex; justify-content:space-between; align-items:center; }
        .topbar-left { display:flex; align-items:center; gap:16px; }
        .topbar-left img { height:46px; filter:drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display:flex; align-items:center; gap:8px; font-size:.9rem; }
        .user-info i { color:#FFC107; }
        .btn-sair { background:rgba(255,255,255,.1); color:white; padding:9px 22px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; }
        .btn-sair:hover { border-color:#FFC107; color:#FFC107; }

        .wrap { max-width:1100px; margin:0 auto; padding:35px 20px 60px; }

        /* HERO */
        .hero { text-align:center; margin-bottom:32px; }
        .hero h1 { font-size:clamp(1.8rem,4vw,2.4rem); font-weight:800; margin-bottom:6px; }
        .hero h1 span { color:#FFC107; }
        .hero p { color:rgba(255,255,255,.55); font-size:.9rem; }

        /* PRÓXIMA AULA */
        .proxima-box { background:rgba(255,193,7,.1); border:1px solid rgba(255,193,7,.3); border-radius:16px; padding:16px 22px; margin-bottom:28px; display:flex; align-items:center; gap:16px; }
        .proxima-box i { font-size:1.6rem; color:#FFC107; flex-shrink:0; }
        .proxima-titulo { font-weight:700; font-size:.95rem; margin-bottom:3px; }
        .proxima-sub { font-size:.82rem; color:rgba(255,255,255,.6); }

        /* STATS */
        .stats-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:28px; }
        .stat-card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.2); border-radius:16px; padding:22px; text-align:center; transition:all .3s; text-decoration:none; color:white; }
        .stat-card:hover { transform:translateY(-4px); border-color:#FFC107; box-shadow:0 10px 30px rgba(255,193,7,.2); }
        .stat-card i { font-size:2rem; color:#FFC107; margin-bottom:12px; display:block; }
        .stat-card .num { font-size:2.2rem; font-weight:800; line-height:1; margin-bottom:6px; }
        .stat-card .lbl { font-size:.78rem; color:rgba(255,255,255,.6); text-transform:uppercase; letter-spacing:.7px; }

        /* VEÍCULO */
        .veiculo-box { background:rgba(255,193,7,.07); border:1px solid rgba(255,193,7,.2); border-radius:14px; padding:16px 20px; margin-bottom:28px; display:flex; align-items:center; gap:14px; }
        .veiculo-icone { width:44px; height:44px; border-radius:12px; background:rgba(255,193,7,.2); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .veiculo-icone i { color:#FFC107; font-size:1.2rem; }
        .veiculo-nome { font-weight:700; font-size:.95rem; }
        .veiculo-sub { font-size:.8rem; color:rgba(255,255,255,.5); }

        /* CARDS AÇÕES */
        .cards-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:18px; }
        .card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.18); border-radius:18px; padding:28px 20px; text-align:center; text-decoration:none; color:white; transition:all .3s; display:block; }
        .card:hover { transform:translateY(-6px); border-color:#FFC107; box-shadow:0 12px 35px rgba(255,193,7,.2); background:rgba(255,255,255,.1); }
        .card-icon { width:60px; height:60px; border-radius:16px; margin:0 auto 16px; background:linear-gradient(135deg,rgba(255,193,7,.25),rgba(255,193,7,.1)); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; }
        .card-icon i { font-size:1.6rem; color:#FFC107; }
        .card h3 { font-size:1rem; font-weight:700; margin-bottom:6px; }
        .card p { color:rgba(255,255,255,.6); font-size:.82rem; line-height:1.5; }

        @media(max-width:700px){ .stats-grid{ grid-template-columns:repeat(2,1fr); } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard_instrutor.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info"><i class="fa fa-user-tie"></i><span><strong><%= username %></strong> (Instrutor)</span></div>
        </div>
        <a href="logout.jsp" class="btn-sair"><i class="fa fa-sign-out-alt"></i>Sair</a>
    </div>

    <div class="wrap">
        <!-- HERO -->
        <div class="hero">
            <h1><%= saudacao %>, <span><%= nomeInstrutor %></span>!</h1>
            <p>Painel do Instrutor — Drive School</p>
        </div>

        <!-- PRÓXIMA AULA HOJE -->
        <% if (proximaAulaHoje != null) { %>
        <div class="proxima-box">
            <i class="fa fa-clock"></i>
            <div>
                <div class="proxima-titulo">Próxima aula hoje às <%= proximaAulaHoje %></div>
                <div class="proxima-sub">Aluno: <%= nomeProximoAluno %></div>
            </div>
        </div>
        <% } else if (aulasDoDia == 0) { %>
        <div class="proxima-box" style="background:rgba(255,255,255,.04);border-color:rgba(255,255,255,.1);">
            <i class="fa fa-calendar-times" style="color:rgba(255,255,255,.3);"></i>
            <div>
                <div class="proxima-titulo" style="color:rgba(255,255,255,.6);">Sem aulas agendadas para hoje</div>
                <div class="proxima-sub">Aproveita para descansar!</div>
            </div>
        </div>
        <% } %>

        <!-- STATS -->
        <div class="stats-grid">
            <a href="minhas_aulas_instrutor.jsp" class="stat-card">
                <i class="fa fa-calendar-day"></i>
                <div class="num"><%= aulasDoDia %></div>
                <div class="lbl">Aulas Hoje</div>
            </a>
            <div class="stat-card">
                <i class="fa fa-user-graduate"></i>
                <div class="num"><%= totalAlunos %></div>
                <div class="lbl">Meus Alunos</div>
            </div>
            <div class="stat-card">
                <i class="fa fa-check-circle"></i>
                <div class="num"><%= aulasRealizadasTotal %></div>
                <div class="lbl">Aulas Realizadas</div>
            </div>
            <a href="minhas_aulas_instrutor.jsp" class="stat-card">
                <i class="fa fa-calendar-alt"></i>
                <div class="num"><%= aulasAgendadasTotal %></div>
                <div class="lbl">Agendadas</div>
            </a>
        </div>

        <!-- VEÍCULO -->
        <div class="veiculo-box">
            <div class="veiculo-icone"><i class="fa fa-car"></i></div>
            <div>
                <div class="veiculo-nome"><%= veiculoInfo %></div>
                <div class="veiculo-sub">Veículo atribuído</div>
            </div>
        </div>

        <!-- CARDS AÇÕES -->
        <div class="cards-grid">
            <a href="minhas_aulas_instrutor.jsp" class="card">
                <div class="card-icon"><i class="fa fa-calendar-alt"></i></div>
                <h3>Minhas Aulas</h3>
                <p>Ver calendário e horário de aulas</p>
            </a>
            <a href="meus_alunos_instrutor.jsp" class="card">
                <div class="card-icon"><i class="fa fa-users"></i></div>
                <h3>Meus Alunos</h3>
                <p>Ver progresso e dados dos alunos</p>
            </a>
            <a href="estado_veiculos.jsp" class="card">
                <div class="card-icon"><i class="fa fa-car-side"></i></div>
                <h3>Estado do Veículo</h3>
                <p>Manutenções, seguros, IUC e IPO</p>
            </a>
            <a href="estatisticas_instrutor.jsp" class="card">
                <div class="card-icon"><i class="fa fa-chart-line"></i></div>
                <h3>Estatísticas</h3>
                <p>Ver estatísticas e relatórios</p>
            </a>
        </div>
    </div>
</body>
</html>
