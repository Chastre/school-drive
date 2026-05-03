<%-- 
    Document   : listar_alunos
    Created on : 16/12/2025, 14:26:30
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // VALIDAÇÃO DE SESSÃO
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
    <title>Gestão de Alunos - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Work Sans', sans-serif;
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
        }
        
        .topbar {
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(10px);
            padding: 15px 0;
            border-bottom: 1px solid rgba(255, 193, 7, 0.2);
        }
        
        .topbar .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .topbar .user-info {
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .topbar .user-info i {
            color: #FFC107;
        }
        
        .btn-sair {
            background: rgba(128, 0, 32, 0.8);
            color: white;
            padding: 10px 25px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .btn-sair:hover {
            background: #800020;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(128, 0, 32, 0.5);
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        
        .logo-link {
            display: block;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo-link img {
            height: 60px;
            width: auto;
            filter: drop-shadow(0 0 10px rgba(255, 193, 7, 0.3));
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 193, 7, 0.2);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .page-header h1 {
            color: white;
            font-size: 2rem;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .page-header h1 i {
            color: #FFC107;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #FFC107 0%, #FFB300 100%);
            color: #1a3a4d;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 193, 7, 0.4);
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: #FFC107;
        }
        
        .btn-edit {
            background: #FFC107;
            color: #1a3a4d;
            padding: 8px 15px;
            font-size: 0.9rem;
        }
        
        .btn-delete {
            background: rgba(244, 67, 54, 0.8);
            color: white;
            padding: 8px 15px;
            font-size: 0.9rem;
        }
        
        .btn-delete:hover {
            background: #F44336;
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        
        .alert i {
            color: #FFC107;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        thead {
            background: linear-gradient(135deg, #1a3a4d 0%, #800020 100%);
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: white;
        }
        
        tbody tr {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            background: transparent;
            transition: all 0.3s;
        }
        
        tbody tr:hover {
            background: rgba(255, 193, 7, 0.1);
        }
        
        td {
            padding: 15px;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .actions {
            display: flex;
            gap: 10px;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: rgba(255, 255, 255, 0.7);
        }
        
        .empty-state i {
            font-size: 4rem;
            color: rgba(255, 193, 7, 0.3);
            margin-bottom: 20px;
        }
        
        /* PESQUISA */
        .search-bar { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,.06); border:1px solid rgba(255,193,7,.25); border-radius:12px; padding:10px 16px; margin-bottom:20px; }
        .search-bar i { color:#FFC107; font-size:1rem; flex-shrink:0; }
        .search-bar input { background:none; border:none; outline:none; color:white; font-family:'Work Sans',sans-serif; font-size:.95rem; width:100%; }
        .search-bar input::placeholder { color:rgba(255,255,255,.35); }
        .search-contador { font-size:.8rem; color:rgba(255,255,255,.45); white-space:nowrap; }
        .sem-resultados { display:none; text-align:center; padding:30px; color:rgba(255,255,255,.4); }

        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .btn-group {
                width: 100%;
                flex-direction: column;
            }
            
            .topbar .container {
                flex-direction: column;
                gap: 10px;
            }
        }
    </style>
</head>
<body>
    <!-- TOPBAR -->
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

    <!-- CONTAINER -->
    <div class="container">
        <!-- LOGO -->
        <a href="dashboard.jsp" class="logo-link">
            <img src="image/logo_mini.png" alt="Drive School">
        </a>

        <div class="content-card">
            <div class="page-header">
                <h1>
                    <i class="fa fa-users"></i>
                    Gestão de Alunos
                </h1>
                <div class="btn-group">
                    <a href="adicionar_aluno.jsp" class="btn btn-primary">
                        <i class="fa fa-plus"></i>
                        Adicionar Aluno
                    </a>
                    <a href="dashboard.jsp" class="btn btn-secondary">
                        <i class="fa fa-arrow-left"></i>
                        Voltar
                    </a>
                </div>
            </div>
            
            <% 
            String msg = request.getParameter("msg");
            if ("success".equals(msg)) { 
            %>
                <div class="alert">
                    <i class="fa fa-check-circle fa-2x"></i>
                    <div>
                        <strong>Sucesso!</strong><br>
                        Aluno adicionado com sucesso!
                    </div>
                </div>
            <% } else if ("updated".equals(msg)) { %>
                <div class="alert">
                    <i class="fa fa-check-circle fa-2x"></i>
                    <div>
                        <strong>Sucesso!</strong><br>
                        Aluno atualizado com sucesso!
                    </div>
                </div>
            <% } else if ("deleted".equals(msg)) { %>
                <div class="alert">
                    <i class="fa fa-info-circle fa-2x"></i>
                    <div>
                        <strong>Removido!</strong><br>
                        Aluno eliminado com sucesso!
                    </div>
                </div>
            <% } %>

            <!-- BARRA DE PESQUISA -->
            <div class="search-bar">
                <i class="fa fa-search"></i>
                <input type="text" id="campoPesquisa" placeholder="Pesquisar por nome, email ou telemóvel..." onkeyup="filtrarTabela()">
                <span class="search-contador" id="contadorResultados"></span>
            </div>

            <div class="table-container">
                <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = ConexaoBD.getConnection();
                    String sql = "SELECT * FROM aluno ORDER BY nome";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    
                    if (!rs.isBeforeFirst()) {
                %>
                        <div class="empty-state">
                            <i class="fa fa-users"></i>
                            <h3>Nenhum aluno encontrado</h3>
                            <p>Clica em "Adicionar Aluno" para começar</p>
                        </div>
                <%
                    } else {
                %>
                        <table id="tabelaAlunos">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Nome</th>
                                    <th>Email</th>
                                    <th>Telemóvel</th>
                                    <th>Categoria</th>
                                    <th>Data Nascimento</th>
                                    <th>Data Inscrição</th>
                                    <th>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                <%
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String nome = rs.getString("nome");
                            String email = rs.getString("email");
                            String telemovel = rs.getString("telemovel");
                            String categoria = rs.getString("categoria");
                            Date dataNascimento = rs.getDate("dataNascimento");
                            Date dataInscricao = rs.getDate("dataInscricao");
                %>
                            <tr class="aluno-row" data-nome="<%= nome != null ? nome.toLowerCase() : "" %>" data-email="<%= email != null ? email.toLowerCase() : "" %>" data-tel="<%= telemovel != null ? telemovel : "" %>">
                                <td><%= id %></td>
                                <td><strong><%= nome %></strong></td>
                                <td><%= email %></td>
                                <td><%= telemovel %></td>
                                <td><%= categoria %></td>
                                <td><%= dataNascimento %></td>
                                <td><%= dataInscricao %></td>
                                <td>
                                    <div class="actions">
                                        <a href="editar_aluno.jsp?id=<%= id %>" class="btn btn-edit">
                                            <i class="fa fa-edit"></i>
                                            Editar
                                        </a>
                                        <a href="eliminar_aluno.jsp?id=<%= id %>" class="btn btn-delete">
                                            <i class="fa fa-trash"></i>
                                            Eliminar
                                        </a>
                                    </div>
                                </td>
                            </tr>
                <%
                        }
                %>
                            </tbody>
                        </table>
                        <div class="sem-resultados" id="semResultados">
                            <i class="fa fa-search fa-2x" style="margin-bottom:10px;display:block;opacity:.3;"></i>
                            Nenhum aluno encontrado com essa pesquisa.
                        </div>
                <%
                    }
                    
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
                %>
            </div>
        </div>
    </div>
    <script>
    function filtrarTabela() {
        var input = document.getElementById('campoPesquisa').value.toLowerCase();
        var rows = document.querySelectorAll('.aluno-row');
        var count = 0;

        rows.forEach(function(row) {
            var nome = row.getAttribute('data-nome') || '';
            var email = row.getAttribute('data-email') || '';
            var tel = row.getAttribute('data-tel') || '';
            var match = nome.includes(input) || email.includes(input) || tel.includes(input);
            row.style.display = match ? '' : 'none';
            if (match) count++;
        });

        var total = rows.length;
        var contador = document.getElementById('contadorResultados');
        if (input === '') {
            contador.textContent = total + ' alunos';
        } else {
            contador.textContent = count + ' de ' + total + ' resultados';
        }

        var semResultados = document.getElementById('semResultados');
        semResultados.style.display = count === 0 && input !== '' ? 'block' : 'none';
    }

    // Inicializar contador
    window.onload = function() {
        var total = document.querySelectorAll('.aluno-row').length;
        document.getElementById('contadorResultados').textContent = total + ' alunos';
    };
    </script>
</body>
</html>
