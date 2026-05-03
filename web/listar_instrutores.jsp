<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Gestão de Instrutores - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Work Sans', sans-serif; background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%); background-attachment: fixed; color: white; min-height: 100vh; }
        .topbar { background: rgba(0,0,0,0.4); backdrop-filter: blur(10px); padding: 15px 0; border-bottom: 1px solid rgba(255,193,7,0.2); }
        .topbar .container { max-width: 1400px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .user-info { color: white; display: flex; align-items: center; gap: 10px; }
        .topbar .user-info i { color: #FFC107; }
        .btn-sair { background: rgba(128,0,32,0.8); color: white; padding: 10px 25px; border-radius: 10px; text-decoration: none; font-weight: 600; transition: all 0.3s; display: inline-flex; align-items: center; gap: 8px; border: 1px solid rgba(255,193,7,0.3); }
        .btn-sair:hover { background: #800020; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(128,0,32,0.5); }
        .container { max-width: 1400px; margin: 0 auto; padding: 40px 20px; }
        .logo-link { display: block; text-align: center; margin-bottom: 30px; }
        .logo-link img { height: 60px; width: auto; filter: drop-shadow(0 0 10px rgba(255,193,7,0.3)); }
        .content-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255,193,7,0.2); border-radius: 20px; padding: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 20px; }
        .page-header h1 { color: white; font-size: 2rem; display: flex; align-items: center; gap: 15px; }
        .page-header h1 i { color: #FFC107; }
        .btn-group { display: flex; gap: 15px; }
        .btn { padding: 12px 25px; border: none; border-radius: 10px; font-size: 1rem; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.3s; }
        .btn-primary { background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%); color: #1a3a4d; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255,193,7,0.4); }
        .btn-secondary { background: rgba(255,255,255,0.1); color: white; border: 2px solid rgba(255,255,255,0.3); }
        .btn-secondary:hover { background: rgba(255,255,255,0.2); border-color: #FFC107; }
        .btn-edit { background: #FFC107; color: #1a3a4d; padding: 8px 15px; font-size: 0.9rem; }
        .btn-delete { background: rgba(244,67,54,0.8); color: white; padding: 8px 15px; font-size: 0.9rem; }
        .btn-delete:hover { background: #F44336; }
        .alert { padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.1); border: 1px solid rgba(255,193,7,0.3); }
        .alert i { color: #FFC107; }
        .table-container { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        thead { background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%); }
        th { padding: 15px; text-align: left; font-weight: 600; color: white; }
        tbody tr { border-bottom: 1px solid rgba(255,255,255,0.1); background: transparent; transition: all 0.3s; }
        tbody tr:hover { background: rgba(255,193,7,0.1); }
        td { padding: 15px; color: rgba(255,255,255,0.9); }
        .actions { display: flex; gap: 10px; }
        .empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,0.7); }
        .empty-state i { font-size: 4rem; color: rgba(255,193,7,0.3); margin-bottom: 20px; }
        .badge { padding: 6px 14px; border-radius: 20px; font-weight: 600; font-size: 0.85rem; display: inline-block; }
        .badge-ativo { background: rgba(76,175,80,0.2); color: #4CAF50; border: 1px solid #4CAF50; }
        .badge-inativo { background: rgba(244,67,54,0.2); color: #F44336; border: 1px solid #F44336; }
        .search-bar { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,.06); border:1px solid rgba(255,193,7,.25); border-radius:12px; padding:10px 16px; margin-bottom:20px; }
        .search-bar i { color:#FFC107; font-size:1rem; flex-shrink:0; }
        .search-bar input { background:none; border:none; outline:none; color:white; font-family:'Work Sans',sans-serif; font-size:.95rem; width:100%; }
        .search-bar input::placeholder { color:rgba(255,255,255,.35); }
        .search-contador { font-size:.8rem; color:rgba(255,255,255,.45); white-space:nowrap; }
        .sem-resultados { display:none; text-align:center; padding:30px; color:rgba(255,255,255,.4); }

        @media (max-width: 768px) { .page-header { flex-direction: column; align-items: flex-start; } .btn-group { width: 100%; flex-direction: column; } .topbar .container { flex-direction: column; gap: 10px; } }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="container">
            <div class="user-info">
                <i class="fa fa-user-shield"></i>
                <span><strong><%= username %></strong></span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <div class="container">
        <a href="dashboard.jsp" class="logo-link">
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="content-card">
            <div class="page-header">
                <h1>
                    <i class="fa fa-chalkboard-teacher"></i>
                    Gestão de Instrutores
                </h1>
                <div class="btn-group">
                    <a href="adicionar_instrutor.jsp" class="btn btn-primary">
                        <i class="fa fa-plus"></i>
                        Adicionar Instrutor
                    </a>
                    <a href="dashboard.jsp" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i>
                        Voltar
                    </a>
                </div>
            </div>

            <%
                String mensagem = request.getParameter("msg");
                if ("success".equals(mensagem)) {
            %>
                <div class="alert">
                    <i class="fa fa-check-circle fa-2x"></i>
                    <div><strong>Sucesso!</strong><br>Operação realizada com sucesso!</div>
                </div>
            <% } else if ("error".equals(mensagem)) { %>
                <div class="alert">
                    <i class="fa fa-exclamation-circle fa-2x"></i>
                    <div><strong>Erro!</strong><br>Erro ao realizar operação!</div>
                </div>
            <% } %>

            <!-- BARRA DE PESQUISA -->
            <div class="search-bar">
                <i class="fa fa-search"></i>
                <input type="text" id="campoPesquisa" placeholder="Pesquisar por nome ou email..." onkeyup="filtrarTabela()">
                <span class="search-contador" id="contadorResultados"></span>
            </div>

            <div class="table-container">
                <%
                    Connection conn = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = ConexaoBD.getConnection();
                        stmt = conn.createStatement();
                        rs = stmt.executeQuery("SELECT * FROM instrutor ORDER BY id DESC");
                        boolean temInstrutores = false;
                        if (!rs.isBeforeFirst()) {
                %>
                    <div class="empty-state">
                        <i class="fa fa-chalkboard-teacher"></i>
                        <h3>Nenhum instrutor registado</h3>
                        <p>Clica em "Adicionar Instrutor" para começar</p>
                    </div>
                <%
                        } else {
                %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nome</th>
                                <th>Email</th>
                                <th>Telemóvel</th>
                                <th>Especialização</th>
                                <th>Data Contratação</th>
                                <th>Estado</th>
                                <th>Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                <%
                            while (rs.next()) {
                                temInstrutores = true;
                                boolean ativo = rs.getBoolean("ativo");
                %>
                            <tr class="inst-row" data-nome="<%= rs.getString("nome") != null ? rs.getString("nome").toLowerCase() : ""%>" data-email="<%= rs.getString("email") != null ? rs.getString("email").toLowerCase() : ""%>">
                                <td><%= rs.getInt("id") %></td>
                                <td><strong><%= rs.getString("nome") %></strong></td>
                                <td><%= rs.getString("email") %></td>
                                <td><%= rs.getString("telemovel") %></td>
                                <td><%= rs.getString("especializado") %></td>
                                <td><%= rs.getDate("dataContratacao") != null ? rs.getDate("dataContratacao") : "N/A" %></td>
                                <td>
                                    <% if (ativo) { %>
                                        <span class="badge badge-ativo"><i class="fa fa-check"></i> Ativo</span>
                                    <% } else { %>
                                        <span class="badge badge-inativo"><i class="fa fa-times"></i> Inativo</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="actions">
                                        <a href="editar_instrutor.jsp?id=<%= rs.getInt("id") %>" class="btn btn-edit">
                                            <i class="fa fa-edit"></i> Editar
                                        </a>
                                        <a href="eliminar_instrutor.jsp?id=<%= rs.getInt("id") %>" class="btn btn-delete">
                                            <i class="fa fa-trash"></i> Eliminar
                                        </a>
                                    </div>
                                </td>
                            </tr>
                <%
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); if (stmt != null) stmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
                        </tbody>
                    </table>
                    <div class="sem-resultados" id="semResultados">
                        <i class="fa fa-search fa-2x" style="margin-bottom:10px;display:block;opacity:.3;"></i>
                        Nenhum instrutor encontrado.
                    </div>
            </div>
        </div>
    </div>

    <script>
    function filtrarTabela() {
        var input = document.getElementById('campoPesquisa').value.toLowerCase();
        var rows = document.querySelectorAll('.inst-row');
        var count = 0;
        rows.forEach(function(row) {
            var match = row.getAttribute('data-nome').includes(input) || row.getAttribute('data-email').includes(input);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });
        var total = rows.length;
        var contador = document.getElementById('contadorResultados');
        contador.textContent = input === '' ? total + ' instrutores' : count + ' de ' + total + ' resultados';
        document.getElementById('semResultados').style.display = count === 0 && input !== '' ? 'block' : 'none';
    }
    window.onload = function() {
        var total = document.querySelectorAll('.inst-row').length;
        document.getElementById('contadorResultados').textContent = total + ' instrutores';
    };
    </script>
    <script>
    function filtrarTabela() {
        var input = document.getElementById('campoPesquisa').value.toLowerCase();
        var rows = document.querySelectorAll('.inst-row');
        var count = 0;
        rows.forEach(function(row) {
            var match = row.getAttribute("data-nome").includes(input) || row.getAttribute("data-email").includes(input);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });
        var total = rows.length;
        document.getElementById('contadorResultados').textContent = input === '' ? total + ' instrutores' : count + ' de ' + total + ' resultados';
        document.getElementById('semResultados').style.display = count === 0 && input !== '' ? 'block' : 'none';
    }
    window.onload = function() {
        document.getElementById('contadorResultados').textContent = document.querySelectorAll('.inst-row').length + ' instrutores';
    };
    </script>
</body>
</html>



