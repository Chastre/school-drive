<%-- 
    Document   : dashboard_professor
    Created on : 04/03/2026, 11:21:40
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    if (!"Professor".equals(session.getAttribute("tipo"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String username = (String) session.getAttribute("username");

    // Estatísticas
    int totalAlunos = 0, totalAulasTeoricasHoje = 0, totalAprovados = 0;
    Connection conn = null;
    try {
        conn = ConexaoBD.getConnection();

        PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM aluno");
        ResultSet rs = ps.executeQuery();
        if (rs.next()) totalAlunos = rs.getInt(1);
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM aula_teorica WHERE data = CURDATE()");
        rs = ps.executeQuery();
        if (rs.next()) totalAulasTeoricasHoje = rs.getInt(1);
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM aluno WHERE aprovadoCodigo = 1");
        rs = ps.executeQuery();
        if (rs.next()) totalAprovados = rs.getInt(1);
        rs.close(); ps.close();

    } catch(Exception e){ e.printStackTrace(); }
    finally { try{ if(conn!=null) conn.close(); }catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Dashboard Professor - Drive School</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); background-attachment:fixed; color:white; min-height:100vh; }

        /* NAVBAR */
        .navbar { background:rgba(0,0,0,0.35); backdrop-filter:blur(12px); border-bottom:1px solid rgba(255,193,7,0.2); position:sticky; top:0; z-index:999; }
        .navbar .wrap { max-width:1200px; margin:0 auto; padding:12px 20px; display:flex; justify-content:space-between; align-items:center; }
        .navbar-brand img { height:52px; filter:drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .navbar-right { display:flex; align-items:center; gap:16px; }
        .user-chip { display:flex; align-items:center; gap:9px; background:rgba(255,255,255,.07); border:1px solid rgba(255,193,7,.2); padding:8px 16px; border-radius:25px; font-size:.88rem; }
        .user-chip i { color:#FFC107; }
        .btn-sair { background:rgba(255,255,255,.1); color:white; padding:9px 22px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; font-size:.9rem; }
        .btn-sair:hover { border-color:#FFC107; color:#FFC107; }

        /* HERO */
        .hero { padding:55px 20px 45px; text-align:center; position:relative; overflow:hidden; }
        .hero::before { content:''; position:absolute; inset:0; background:radial-gradient(ellipse at 50% 0%,rgba(255,193,7,.1) 0%,transparent 65%); pointer-events:none; }
        .hero h1 { font-size:clamp(1.8rem,4vw,2.8rem); font-weight:800; margin-bottom:10px; }
        .hero h1 span { color:#FFC107; }
        .hero p { color:rgba(255,255,255,.65); font-size:1rem; }

        /* STATS */
        .stats-bar { background:rgba(0,0,0,.2); border-top:1px solid rgba(255,193,7,.12); border-bottom:1px solid rgba(255,193,7,.12); padding:24px 20px; }
        .stats-bar .wrap { max-width:700px; margin:0 auto; display:flex; justify-content:space-around; flex-wrap:wrap; gap:20px; }
        .stat-item { text-align:center; }
        .stat-item .num { font-size:2.2rem; font-weight:800; color:#FFC107; }
        .stat-item .lbl { font-size:.78rem; color:rgba(255,255,255,.6); text-transform:uppercase; letter-spacing:.8px; margin-top:3px; }

        /* CARDS */
        .section { padding:50px 20px; }
        .wrap { max-width:1200px; margin:0 auto; }
        .cards-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:22px; }
        .card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.18); border-radius:18px; padding:32px 26px; text-align:center; text-decoration:none; color:white; transition:all .3s; cursor:pointer; }
        .card:hover { transform:translateY(-7px); background:rgba(255,255,255,.1); border-color:#FFC107; box-shadow:0 14px 40px rgba(255,193,7,.18); }
        .card-icon { width:65px; height:65px; border-radius:16px; margin:0 auto 18px; background:linear-gradient(135deg,rgba(255,193,7,.25),rgba(255,193,7,.1)); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; }
        .card-icon i { font-size:1.8rem; color:#FFC107; }
        .card h3 { font-size:1.1rem; font-weight:700; margin-bottom:8px; }
        .card p { color:rgba(255,255,255,.65); font-size:.88rem; line-height:1.6; }

        /* FOOTER */
        .footer { background:rgba(0,0,0,.3); border-top:1px solid rgba(255,193,7,.1); padding:24px 20px; text-align:center; color:rgba(255,255,255,.45); font-size:.82rem; }
    </style>
</head>
<body>

    <nav class="navbar">
        <div class="wrap">
            <a href="dashboard_professor.jsp" class="navbar-brand">
                <img src="image/logo_mini.png" alt="Drive School">
            </a>
            <div class="navbar-right">
                <div class="user-chip">
                    <i class="fa fa-chalkboard-teacher"></i>
                    <span><strong><%= username %></strong> — Professor</span>
                </div>
                <a href="logout.jsp" class="btn-sair">
                    <i class="fa fa-sign-out-alt"></i>Sair
                </a>
            </div>
        </div>
    </nav>

    <section class="hero">
        <h1>Bem-vindo, <span><%= username %></span>!</h1>
        <p>Painel do Professor de Código — Drive School</p>
    </section>

    <div class="stats-bar">
        <div class="wrap">
            <div class="stat-item">
                <div class="num"><%= totalAlunos %></div>
                <div class="lbl">Total Alunos</div>
            </div>
            <div class="stat-item">
                <div class="num"><%= totalAulasTeoricasHoje %></div>
                <div class="lbl">Aulas Hoje</div>
            </div>
            <div class="stat-item">
                <div class="num"><%= totalAprovados %></div>
                <div class="lbl">Aprovados Código</div>
            </div>
        </div>
    </div>

    <section class="section">
        <div class="wrap">
            <div class="cards-grid">
                <a href="gerir_aulas_teoricas.jsp" class="card">
                    <div class="card-icon"><i class="fa fa-chalkboard"></i></div>
                    <h3>Aulas Teóricas</h3>
                    <p>Regista aulas de código e acompanha o progresso de cada aluno</p>
                </a>
                <a href="listar_alunos_professor.jsp" class="card">
                    <div class="card-icon"><i class="fa fa-users"></i></div>
                    <h3>Ver Alunos</h3>
                    <p>Consulta o progresso e as aulas de condução de cada aluno</p>
                </a>
            </div>
        </div>
    </section>

    <footer class="footer">
        &copy; 2026 Drive School — Escola de Condução, Matosinhos
    </footer>

</body>
</html>
