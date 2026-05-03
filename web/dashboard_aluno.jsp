<%-- 
    Document   : dashboard_aluno
    Created on : 18/12/2025, 01:06:49
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Aluno".equals(tipo)) { response.sendRedirect("login.jsp"); return; }
    String username = (String) session.getAttribute("username");

    // Buscar dados do aluno
    String nomeAluno = username;
    int totalTeorica = 0, totalConducao = 0;
    int acessoConducao = 0, aprovadoCodigo = 0;
    String nomeInstrutor = "-";

    Connection conn = null;
    try {
        conn = ConexaoBD.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT a.nome, a.acessoConducao, a.aprovadoCodigo, i.nome as nomeInstrutor " +
            "FROM t_utilizador u " +
            "JOIN aluno a ON u.idAluno = a.id " +
            "LEFT JOIN instrutor i ON a.idInstrutor = i.id " +
            "WHERE u.username = ?");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            nomeAluno = rs.getString("nome") != null ? rs.getString("nome") : username;
            acessoConducao = rs.getInt("acessoConducao");
            aprovadoCodigo = rs.getInt("aprovadoCodigo");
            nomeInstrutor = rs.getString("nomeInstrutor") != null ? rs.getString("nomeInstrutor") : "-";
        }
        rs.close(); ps.close();

        // Total aulas teóricas
        ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM aula_teorica at2 " +
            "JOIN aluno a ON a.id = at2.idAluno " +
            "JOIN t_utilizador u ON u.idAluno = a.id " +
            "WHERE u.username = ? AND at2.estado = 'realizada'");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) totalTeorica = rs.getInt(1);
        rs.close(); ps.close();

        // Total aulas condução
        ps = conn.prepareStatement(
            "SELECT COUNT(*) FROM aula_conducao ac " +
            "JOIN aluno a ON a.id = ac.idAluno " +
            "JOIN t_utilizador u ON u.idAluno = a.id " +
            "WHERE u.username = ? AND ac.estado != 'cancelada'");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) totalConducao = rs.getInt(1);
        rs.close(); ps.close();

    } catch(Exception e){ e.printStackTrace(); }
    finally { try{ if(conn!=null) conn.close(); }catch(Exception e){} }

    int limiteConducao = aprovadoCodigo == 1 ? 30 : 15;
    int pctTeorica = Math.min(100, totalTeorica * 5);
    int pctConducao = limiteConducao > 0 ? Math.min(100, totalConducao * 100 / limiteConducao) : 0;

    // Fase atual do aluno
    String fase = "teorica";
    if (aprovadoCodigo == 1) fase = "conducao_pos";
    else if (acessoConducao == 1) fase = "conducao_pre";
    else if (totalTeorica >= 20) fase = "aguarda_acesso";
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Dashboard - Drive School</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); background-attachment:fixed; color:white; min-height:100vh; }

        /* TOPBAR */
        .topbar { background:rgba(0,0,0,0.4); backdrop-filter:blur(10px); padding:12px 30px; border-bottom:1px solid rgba(255,193,7,0.2); display:flex; justify-content:space-between; align-items:center; }
        .topbar-left { display:flex; align-items:center; gap:16px; }
        .topbar-left img { height:46px; filter:drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display:flex; align-items:center; gap:8px; font-size:.9rem; }
        .user-info i { color:#FFC107; }
        .btn-sair { background:rgba(255,255,255,.1); color:white; padding:9px 22px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; }
        .btn-sair:hover { border-color:#FFC107; color:#FFC107; }

        /* HERO */
        .hero { padding:45px 20px 30px; text-align:center; }
        .hero h1 { font-size:clamp(1.8rem,4vw,2.6rem); font-weight:800; margin-bottom:6px; }
        .hero h1 span { color:#FFC107; }
        .hero p { color:rgba(255,255,255,.6); font-size:.95rem; }

        .wrap { max-width:1000px; margin:0 auto; padding:0 20px 60px; }

        /* PROGRESSO */
        .progresso-section { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.2); border-radius:20px; padding:28px; margin-bottom:28px; }
        .progresso-title { font-size:.78rem; text-transform:uppercase; letter-spacing:1px; color:#FFC107; font-weight:700; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
        .progresso-title::after { content:''; flex:1; height:1px; background:rgba(255,193,7,.2); }

        .passos { display:flex; align-items:center; gap:0; margin-bottom:28px; overflow-x:auto; }
        .passo { display:flex; flex-direction:column; align-items:center; gap:6px; flex:1; min-width:100px; }
        .passo-circulo { width:44px; height:44px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:1.1rem; font-weight:800; border:2px solid transparent; transition:all .3s; }
        .passo-circulo.feito { background:linear-gradient(135deg,#28a745,#20c040); border-color:#28a745; }
        .passo-circulo.atual { background:linear-gradient(135deg,#FFC107,#FFB300); border-color:#FFC107; color:#1a3a4d; }
        .passo-circulo.pendente { background:rgba(255,255,255,.08); border-color:rgba(255,255,255,.2); color:rgba(255,255,255,.4); }
        .passo-label { font-size:.72rem; text-align:center; color:rgba(255,255,255,.7); font-weight:600; }
        .passo-label.atual { color:#FFC107; }
        .passo-linha { flex:1; height:2px; background:rgba(255,255,255,.1); margin-top:-22px; min-width:20px; }
        .passo-linha.feita { background:linear-gradient(90deg,#28a745,#20c040); }

        .stats-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; }
        .stat-card { background:rgba(255,255,255,.05); border:1px solid rgba(255,193,7,.15); border-radius:14px; padding:18px; text-align:center; }
        .stat-num { font-size:1.8rem; font-weight:800; color:#FFC107; }
        .stat-lbl { font-size:.75rem; color:rgba(255,255,255,.6); text-transform:uppercase; letter-spacing:.7px; margin-top:3px; }
        .stat-bar { height:5px; background:rgba(255,255,255,.1); border-radius:5px; margin-top:10px; overflow:hidden; }
        .stat-bar-fill { height:100%; border-radius:5px; background:linear-gradient(90deg,#FFC107,#FFB300); }
        .stat-bar-fill.verde { background:linear-gradient(90deg,#28a745,#20c040); }
        .stat-bar-fill.azul { background:linear-gradient(90deg,#2196F3,#1976D2); }

        /* AVISO FASE */
        .aviso { border-radius:14px; padding:16px 20px; margin-bottom:22px; display:flex; align-items:flex-start; gap:14px; }
        .aviso i { font-size:1.4rem; flex-shrink:0; margin-top:2px; }
        .aviso-titulo { font-weight:700; margin-bottom:4px; }
        .aviso-texto { font-size:.88rem; color:rgba(255,255,255,.8); line-height:1.6; }
        .aviso-amarelo { background:rgba(255,193,7,.12); border:1px solid rgba(255,193,7,.3); }
        .aviso-amarelo i { color:#FFC107; }
        .aviso-verde { background:rgba(40,167,69,.12); border:1px solid rgba(40,167,69,.3); }
        .aviso-verde i { color:#a8f0b8; }
        .aviso-azul { background:rgba(33,150,243,.12); border:1px solid rgba(33,150,243,.3); }
        .aviso-azul i { color:#90caf9; }

        /* INSTRUTOR */
        .instrutor-box { background:rgba(255,193,7,.07); border:1px solid rgba(255,193,7,.2); border-radius:14px; padding:16px 20px; margin-bottom:22px; display:flex; align-items:center; gap:14px; }
        .instrutor-avatar { width:44px; height:44px; border-radius:12px; background:rgba(255,193,7,.2); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .instrutor-avatar i { color:#FFC107; font-size:1.2rem; }
        .instrutor-nome { font-weight:700; font-size:.95rem; }
        .instrutor-sub { font-size:.8rem; color:rgba(255,255,255,.55); }

        /* CARDS AÇÕES */
        .cards-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:18px; }
        .card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.18); border-radius:18px; padding:28px 20px; text-align:center; text-decoration:none; color:white; transition:all .3s; }
        .card:hover { transform:translateY(-6px); border-color:#FFC107; box-shadow:0 12px 35px rgba(255,193,7,.2); background:rgba(255,255,255,.1); }
        .card.bloqueado { opacity:.45; cursor:not-allowed; pointer-events:none; }
        .card-icon { width:60px; height:60px; border-radius:16px; margin:0 auto 16px; background:linear-gradient(135deg,rgba(255,193,7,.25),rgba(255,193,7,.1)); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; }
        .card-icon i { font-size:1.6rem; color:#FFC107; }
        .card h3 { font-size:1rem; font-weight:700; margin-bottom:6px; }
        .card p { color:rgba(255,255,255,.6); font-size:.82rem; line-height:1.5; }

        @media(max-width:600px){ .stats-grid{ grid-template-columns:1fr; } .passos{ gap:0; } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard_aluno.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info">
                <i class="fa fa-user-graduate"></i>
                <span><strong><%= username %></strong> (Aluno)</span>
            </div>
        </div>
        <a href="logout.jsp" class="btn-sair"><i class="fa fa-sign-out-alt"></i>Sair</a>
    </div>

    <section class="hero">
        <h1>Bem-vindo, <span><%= nomeAluno %></span>!</h1>
        <p>Acompanha o teu percurso na Drive School</p>
    </section>

    <div class="wrap">

        <!-- AVISO DE FASE -->
        <%
        if ("teorica".equals(fase)) {
            int faltam = 20 - totalTeorica;
        %>
        <div class="aviso aviso-amarelo">
            <i class="fa fa-chalkboard"></i>
            <div>
                <div class="aviso-titulo">Fase: Aulas Teóricas</div>
                <div class="aviso-texto">Estás na fase das aulas de código. Faltam <strong><%= faltam %> aulas teóricas</strong> para poderes aceder às aulas de condução.</div>
            </div>
        </div>
        <% } else if ("aguarda_acesso".equals(fase)) { %>
        <div class="aviso aviso-azul">
            <i class="fa fa-hourglass-half"></i>
            <div>
                <div class="aviso-titulo">Aguarda autorização</div>
                <div class="aviso-texto">Já completaste as 20 aulas teóricas! O administrador irá dar-te acesso às aulas de condução em breve.</div>
            </div>
        </div>
        <% } else if ("conducao_pre".equals(fase)) { %>
        <div class="aviso aviso-verde">
            <i class="fa fa-car"></i>
            <div>
                <div class="aviso-titulo">🎉 Acesso à condução ativo!</div>
                <div class="aviso-texto">Já podes agendar aulas de condução. Podes fazer até <strong>15 aulas</strong> antes do exame de código.</div>
            </div>
        </div>
        <% } else if ("conducao_pos".equals(fase)) { %>
        <div class="aviso aviso-verde">
            <i class="fa fa-graduation-cap"></i>
            <div>
                <div class="aviso-titulo">✅ Código aprovado!</div>
                <div class="aviso-texto">Parabéns pela aprovação! Podes continuar as aulas de condução até ao máximo de <strong>30 aulas</strong>.</div>
            </div>
        </div>
        <% } %>

        <!-- PROGRESSO -->
        <div class="progresso-section">
            <div class="progresso-title"><i class="fa fa-route"></i> O teu percurso</div>

            <!-- PASSOS -->
            <%
            String c1 = totalTeorica >= 20 ? "feito" : "atual";
            String c2 = aprovadoCodigo == 1 ? "feito" : (acessoConducao == 1 ? "atual" : "pendente");
            String c3 = totalConducao >= limiteConducao ? "feito" : (aprovadoCodigo == 1 ? "atual" : "pendente");
            String l1 = totalTeorica >= 20 ? "feita" : "";
            String l2 = aprovadoCodigo == 1 ? "feita" : "";
            %>
            <div class="passos">
                <div class="passo">
                    <div class="passo-circulo <%= c1 %>">
                        <% if (totalTeorica >= 20) { %><i class="fa fa-check"></i><% } else { %>1<% } %>
                    </div>
                    <div class="passo-label <%= "atual".equals(c1) ? "atual" : "" %>">Aulas<br>Teóricas</div>
                </div>
                <div class="passo-linha <%= l1 %>"></div>
                <div class="passo">
                    <div class="passo-circulo <%= c2 %>">
                        <% if (aprovadoCodigo == 1) { %><i class="fa fa-check"></i><% } else { %>2<% } %>
                    </div>
                    <div class="passo-label <%= "atual".equals(c2) ? "atual" : "" %>">Exame<br>Código</div>
                </div>
                <div class="passo-linha <%= l2 %>"></div>
                <div class="passo">
                    <div class="passo-circulo <%= c3 %>">
                        <% if (totalConducao >= limiteConducao) { %><i class="fa fa-check"></i><% } else { %>3<% } %>
                    </div>
                    <div class="passo-label <%= "atual".equals(c3) ? "atual" : "" %>">Aulas<br>Condução</div>
                </div>
                <div class="passo-linha"></div>
                <div class="passo">
                    <div class="passo-circulo pendente">4</div>
                    <div class="passo-label">Exame<br>Final</div>
                </div>
            </div>

            <!-- STATS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-num"><%= totalTeorica %>/20</div>
                    <div class="stat-lbl">Aulas Teóricas</div>
                    <div class="stat-bar"><div class="stat-bar-fill verde" style="width:<%= pctTeorica %>%"></div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-num" style="font-size:1.3rem"><%= aprovadoCodigo == 1 ? "✅ Aprovado" : "⏳ Pendente" %></div>
                    <div class="stat-lbl">Exame de Código</div>
                </div>
                <div class="stat-card">
                    <div class="stat-num"><%= totalConducao %>/<%= limiteConducao %></div>
                    <div class="stat-lbl">Aulas Condução</div>
                    <div class="stat-bar"><div class="stat-bar-fill azul" style="width:<%= pctConducao %>%"></div></div>
                </div>
            </div>
        </div>

        <!-- INSTRUTOR -->
        <div class="instrutor-box">
            <div class="instrutor-avatar"><i class="fa fa-user-tie"></i></div>
            <div>
                <div class="instrutor-nome"><%= nomeInstrutor %></div>
                <div class="instrutor-sub">O teu instrutor atribuído</div>
            </div>
        </div>

        <!-- CARDS AÇÕES -->
        <div class="cards-grid">
            <a href="minhas_aulas_aluno.jsp" class="card">
                <div class="card-icon"><i class="fa fa-calendar-week"></i></div>
                <h3>Minhas Aulas</h3>
                <p>Ver calendário e histórico de aulas de condução</p>
            </a>

            <% if (acessoConducao == 1) { %>
            <a href="agendar_aula.jsp" class="card">
                <div class="card-icon"><i class="fa fa-calendar-plus"></i></div>
                <h3>Agendar Aula</h3>
                <p>Marcar nova aula de condução</p>
            </a>
            <% } else { %>
            <div class="card bloqueado">
                <div class="card-icon"><i class="fa fa-lock"></i></div>
                <h3>Agendar Aula</h3>
                <p>Disponível após 20 aulas teóricas</p>
            </div>
            <% } %>

            <a href="meus_pagamentos.jsp" class="card">
                <div class="card-icon"><i class="fa fa-money-bill-wave"></i></div>
                <h3>Meus Pagamentos</h3>
                <p>Consultar pagamentos e pendências</p>
            </a>
        </div>
    </div>
</body>
</html>
