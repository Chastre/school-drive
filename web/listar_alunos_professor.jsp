<%-- 
    Document   : listar_alunos_professor
    Created on : 04/03/2026, 11:40:39
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
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

    // Buscar todos os alunos com estatísticas
    List<String[]> alunos = new ArrayList<>();
    Connection conn = null;
    try {
        conn = ConexaoBD.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT a.id, a.nome, a.email, a.telemovel, a.categoria, " +
            "a.acessoConducao, a.aprovadoCodigo, " +
            "(SELECT COUNT(*) FROM aula_teorica at WHERE at.idAluno = a.id AND at.estado = 'realizada') as totalTeorica, " +
            "(SELECT COUNT(*) FROM aula_conducao ac WHERE ac.idAluno = a.id AND ac.estado != 'cancelada') as totalConducao " +
            "FROM aluno a ORDER BY a.nome"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            alunos.add(new String[]{
                rs.getString("id"),
                rs.getString("nome"),
                rs.getString("email"),
                rs.getString("telemovel"),
                rs.getString("categoria"),
                rs.getString("acessoConducao"),
                rs.getString("aprovadoCodigo"),
                rs.getString("totalTeorica"),
                rs.getString("totalConducao")
            });
        }
        rs.close(); ps.close();
    } catch(Exception e){ e.printStackTrace(); }
    finally { try{ if(conn!=null) conn.close(); }catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Alunos - Professor</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Work Sans',sans-serif; background:linear-gradient(135deg,#1a3a4d 0%,#800020 100%); background-attachment:fixed; color:white; min-height:100vh; }

        .topbar { background:rgba(0,0,0,0.4); backdrop-filter:blur(10px); border-bottom:1px solid rgba(255,193,7,0.2); padding:12px 30px; display:flex; justify-content:space-between; align-items:center; }
        .topbar-left { display:flex; align-items:center; gap:18px; }
        .topbar-left img { height:46px; filter:drop-shadow(0 0 8px rgba(255,193,7,0.3)); }
        .user-info { display:flex; align-items:center; gap:8px; font-size:.9rem; }
        .user-info i { color:#FFC107; }
        .btn-voltar { background:rgba(255,255,255,.1); color:white; padding:8px 20px; border-radius:25px; text-decoration:none; font-weight:600; border:2px solid rgba(255,255,255,.3); display:inline-flex; align-items:center; gap:7px; transition:all .3s; font-size:.9rem; }
        .btn-voltar:hover { border-color:#FFC107; color:#FFC107; }

        .wrap { max-width:1200px; margin:0 auto; padding:35px 20px; }
        .page-title { font-size:1.8rem; font-weight:800; margin-bottom:8px; display:flex; align-items:center; gap:12px; }
        .page-title i { color:#FFC107; }
        .page-sub { color:rgba(255,255,255,.55); font-size:.9rem; margin-bottom:30px; }

        /* PESQUISA */
        .search-bar { position:relative; margin-bottom:24px; }
        .search-bar input { width:100%; padding:13px 18px 13px 46px; border-radius:25px; border:1px solid rgba(255,255,255,.2); background:rgba(255,255,255,.07); color:white; font-family:'Work Sans',sans-serif; font-size:.95rem; transition:all .3s; }
        .search-bar input::placeholder { color:rgba(255,255,255,.35); }
        .search-bar input:focus { outline:none; border-color:#FFC107; background:rgba(255,255,255,.1); }
        .search-bar i { position:absolute; left:16px; top:50%; transform:translateY(-50%); color:rgba(255,193,7,.6); }

        /* CARDS ALUNOS */
        .alunos-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(340px,1fr)); gap:20px; }
        .aluno-card { background:rgba(255,255,255,.05); backdrop-filter:blur(10px); border:1px solid rgba(255,193,7,.15); border-radius:18px; padding:24px; transition:all .3s; }
        .aluno-card:hover { transform:translateY(-4px); border-color:rgba(255,193,7,.35); box-shadow:0 12px 35px rgba(0,0,0,.25); }

        /* HEADER DO CARD */
        .aluno-header { display:flex; align-items:center; gap:14px; margin-bottom:18px; }
        .aluno-avatar { width:48px; height:48px; border-radius:14px; background:linear-gradient(135deg,rgba(255,193,7,.25),rgba(255,193,7,.1)); border:1px solid rgba(255,193,7,.3); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .aluno-avatar i { color:#FFC107; font-size:1.3rem; }
        .aluno-nome { font-size:1.05rem; font-weight:700; margin-bottom:3px; }
        .aluno-categoria { font-size:.78rem; color:rgba(255,255,255,.5); }

        /* CONTACTOS */
        .aluno-contactos { display:flex; flex-direction:column; gap:5px; margin-bottom:18px; padding-bottom:16px; border-bottom:1px solid rgba(255,255,255,.07); }
        .contacto-item { display:flex; align-items:center; gap:8px; font-size:.83rem; color:rgba(255,255,255,.7); }
        .contacto-item i { color:#FFC107; width:14px; font-size:.8rem; }

        /* PROGRESSO */
        .progresso-section { display:flex; flex-direction:column; gap:12px; margin-bottom:16px; }
        .prog-item { display:flex; flex-direction:column; gap:5px; }
        .prog-header { display:flex; justify-content:space-between; align-items:center; }
        .prog-label { font-size:.78rem; color:rgba(255,255,255,.6); }
        .prog-valor { font-size:.82rem; font-weight:700; color:#FFC107; }
        .prog-bar { height:6px; background:rgba(255,255,255,.1); border-radius:6px; overflow:hidden; }
        .prog-fill { height:100%; border-radius:6px; background:linear-gradient(90deg,#FFC107,#FFB300); transition:width .6s; }
        .prog-fill.completo { background:linear-gradient(90deg,#28a745,#20c040); }
        .prog-fill.conducao { background:linear-gradient(90deg,#2196F3,#1976D2); }

        /* BADGES */
        .badges-row { display:flex; gap:8px; flex-wrap:wrap; }
        .badge { font-size:.72rem; padding:4px 10px; border-radius:10px; font-weight:700; display:inline-flex; align-items:center; gap:5px; }
        .badge-acesso   { background:rgba(40,167,69,.25); color:#a8f0b8; border:1px solid rgba(40,167,69,.4); }
        .badge-noacesso { background:rgba(255,255,255,.07); color:rgba(255,255,255,.4); border:1px solid rgba(255,255,255,.1); }
        .badge-aprovado { background:rgba(255,193,7,.2); color:#FFC107; border:1px solid rgba(255,193,7,.4); }
        .badge-reprovado{ background:rgba(220,53,69,.2); color:#f5a0a8; border:1px solid rgba(220,53,69,.3); }

        /* EMPTY */
        .empty { text-align:center; padding:60px 20px; color:rgba(255,255,255,.35); }
        .empty i { font-size:3rem; margin-bottom:14px; display:block; }

        @media(max-width:600px){ .alunos-grid{ grid-template-columns:1fr; } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-left">
            <a href="dashboard_professor.jsp"><img src="image/logo_mini.png" alt="Drive School"></a>
            <div class="user-info"><i class="fa fa-chalkboard-teacher"></i><span><strong><%= username %></strong> — Professor</span></div>
        </div>
        <a href="dashboard_professor.jsp" class="btn-voltar"><i class="fa fa-arrow-left"></i>Dashboard</a>
    </div>

    <div class="wrap">
        <div class="page-title"><i class="fa fa-users"></i>Lista de Alunos</div>
        <div class="page-sub"><%= alunos.size() %> aluno<%= alunos.size() != 1 ? "s" : "" %> registado<%= alunos.size() != 1 ? "s" : "" %></div>

        <div class="search-bar">
            <i class="fa fa-search"></i>
            <input type="text" id="pesquisa" placeholder="Pesquisar por nome, email ou telemóvel..." onkeyup="filtrar()">
        </div>

        <% if (alunos.isEmpty()) { %>
            <div class="empty"><i class="fa fa-user-slash"></i>Nenhum aluno registado</div>
        <% } else { %>
        <div class="alunos-grid" id="grid">
            <% for (String[] a : alunos) {
                int totalTeorica = Integer.parseInt(a[7] != null ? a[7] : "0");
                int totalConducao = Integer.parseInt(a[8] != null ? a[8] : "0");
                boolean temAcesso = "1".equals(a[5]);
                boolean aprovado = "1".equals(a[6]);
                int pctTeorica = Math.min(100, totalTeorica * 5);
                int limiteConducao = aprovado ? 30 : 15;
                int pctConducao = limiteConducao > 0 ? Math.min(100, totalConducao * 100 / limiteConducao) : 0;
            %>
            <div class="aluno-card" data-search="<%= a[1].toLowerCase() %> <%= a[2] != null ? a[2].toLowerCase() : "" %> <%= a[3] != null ? a[3] : "" %>">
                <div class="aluno-header">
                    <div class="aluno-avatar"><i class="fa fa-user-graduate"></i></div>
                    <div>
                        <div class="aluno-nome"><%= a[1] %></div>
                        <div class="aluno-categoria">Categoria <%= a[4] != null ? a[4] : "-" %></div>
                    </div>
                </div>

                <div class="aluno-contactos">
                    <div class="contacto-item"><i class="fa fa-envelope"></i><%= a[2] != null ? a[2] : "-" %></div>
                    <div class="contacto-item"><i class="fa fa-phone"></i><%= a[3] != null ? a[3] : "-" %></div>
                </div>

                <div class="progresso-section">
                    <div class="prog-item">
                        <div class="prog-header">
                            <span class="prog-label"><i class="fa fa-chalkboard" style="margin-right:5px"></i>Aulas Teóricas</span>
                            <span class="prog-valor"><%= totalTeorica %>/20</span>
                        </div>
                        <div class="prog-bar"><div class="prog-fill <%= totalTeorica>=20?"completo":"" %>" style="width:<%= pctTeorica %>%"></div></div>
                    </div>
                    <div class="prog-item">
                        <div class="prog-header">
                            <span class="prog-label"><i class="fa fa-car" style="margin-right:5px"></i>Aulas de Condução</span>
                            <span class="prog-valor"><%= totalConducao %>/<%= limiteConducao %></span>
                        </div>
                        <div class="prog-bar"><div class="prog-fill conducao <%= totalConducao>=limiteConducao?"completo":"" %>" style="width:<%= pctConducao %>%"></div></div>
                    </div>
                </div>

                <div class="badges-row">
                    <span class="badge <%= temAcesso ? "badge-acesso" : "badge-noacesso" %>">
                        <i class="fa fa-<%= temAcesso ? "unlock" : "lock" %>"></i>
                        <%= temAcesso ? "Condução ativa" : "Sem acesso condução" %>
                    </span>
                    <span class="badge <%= aprovado ? "badge-aprovado" : "badge-reprovado" %>">
                        <i class="fa fa-graduation-cap"></i>
                        <%= aprovado ? "Código aprovado" : "Código pendente" %>
                    </span>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <script>
        function filtrar() {
            const termo = document.getElementById('pesquisa').value.toLowerCase();
            document.querySelectorAll('.aluno-card').forEach(card => {
                const texto = card.getAttribute('data-search');
                card.style.display = texto.includes(termo) ? '' : 'none';
            });
        }
    </script>
</body>
</html>

