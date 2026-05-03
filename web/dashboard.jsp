<%-- 
    Document   : dashboard
    Created on : 18/12/2025, 01:07:31
    Author     : pmnch
--%>

<%-- 
    Document   : dashboard
    Created on : 18/12/2025, 01:07:31
    Author     : pmnch
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // VALIDAÇÃO DE SESSÃO
    if (session.getAttribute("logado") == null || !((Boolean)session.getAttribute("logado"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String tipo = (String) session.getAttribute("tipo");
    if (!"Admin".equals(tipo)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Dashboard Admin - Escola de Condução</title>
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
        
        /* TOPBAR */
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
        
        /* NAVBAR */
        .navbar {
            background: rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(10px);
            padding: 15px 0;
        }
        
        .navbar .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .navbar-brand {
            display: flex;
            align-items: center;
            text-decoration: none;
        }
        
        .navbar-brand img {
            height: 60px;
            width: auto;
            filter: drop-shadow(0 0 10px rgba(255, 193, 7, 0.3));
            transition: all 0.3s;
        }
        
        .navbar-brand img:hover {
            transform: scale(1.05);
            filter: drop-shadow(0 0 15px rgba(255, 193, 7, 0.5));
        }
        
        /* HERO */
        .hero {
            padding: 60px 20px;
            text-align: center;
        }
        
        .hero h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            color: white;
            text-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        .hero p {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.8);
        }
        
        /* CARDS */
        .cards-section {
            padding: 40px 20px 80px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
        }
        
        .card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 193, 7, 0.2);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            transition: all 0.3s;
            text-decoration: none;
            display: block;
        }
        
        .card:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.1);
            border-color: #FFC107;
            box-shadow: 0 15px 40px rgba(255, 193, 7, 0.3);
        }
        
        .card-icon {
            font-size: 4rem;
            margin-bottom: 20px;
        }
        
        .card-icon.alunos { color: #4CAF50; }
        .card-icon.instrutores { color: #2196F3; }
        .card-icon.veiculos { color: #FF9800; }
        .card-icon.aulas { color: #9C27B0; }
        .card-icon.pagamentos { color: #FFC107; }
        .card-icon.manutencao { color: #F44336; }
        .card-icon.teoricas { color: #00BCD4; }
        
        .card h3 {
            font-size: 1.5rem;
            color: white;
            margin-bottom: 10px;
        }
        
        .card p {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.95rem;
        }
        
        /* RESPONSIVE */
        @media (max-width: 768px) {
            .hero h1 {
                font-size: 2rem;
            }
            
            .topbar .container {
                flex-direction: column;
                gap: 15px;
            }
            
            .cards-grid {
                grid-template-columns: 1fr;
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
                <span><strong><%= username %></strong> (Administrador)</span>
            </div>
            <a href="logout.jsp" class="btn-sair">
                <i class="fa fa-sign-out-alt"></i>
                Sair
            </a>
        </div>
    </div>

    <!-- NAVBAR -->
    <nav class="navbar">
        <div class="container">
            <a href="dashboard.jsp" class="navbar-brand">
                <img src="image/logo_mini.png" alt="Drive School">
            </a>
        </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
        <h1>Painel de Administração</h1>
        <p>Bem-vindo ao sistema de gestão da escola de condução</p>
    </section>

    <!-- CARDS -->
    <section class="cards-section">
        <div class="container">
            <div class="cards-grid">
                <a href="listar_alunos.jsp" class="card">
                    <div class="card-icon alunos">
                        <i class="fa fa-users"></i>
                    </div>
                    <h3>Gestão de Alunos</h3>
                    <p>Controle completo de alunos, documentos e progresso</p>
                </a>

                <a href="listar_instrutores.jsp" class="card">
                    <div class="card-icon instrutores">
                        <i class="fa fa-chalkboard-teacher"></i>
                    </div>
                    <h3>Gestão de Instrutores</h3>
                    <p>Organize horários e especialidades dos instrutores</p>
                </a>

                <a href="listar_veiculos.jsp" class="card">
                    <div class="card-icon veiculos">
                        <i class="fa fa-car"></i>
                    </div>
                    <h3>Gestão de Veículos</h3>
                    <p>Controle de veículos e manutenções</p>
                </a>

                <a href="listar_aulas.jsp" class="card">
                    <div class="card-icon aulas">
                        <i class="fa fa-graduation-cap"></i>
                    </div>
                    <h3>Aulas de Condução</h3>
                    <p>Agendamento e acompanhamento de aulas</p>
                </a>

                <a href="listar_pagamentos.jsp" class="card">
                    <div class="card-icon pagamentos">
                        <i class="fa fa-money-bill-wave"></i>
                    </div>
                    <h3>Gestão de Pagamentos</h3>
                    <p>Controle de pagamentos e mensalidades</p>
                </a>

                <a href="listar_manutencoes.jsp" class="card">
                    <div class="card-icon manutencao">
                        <i class="fa fa-tools"></i>
                    </div>
                    <h3>Manutenção de Veículos</h3>
                    <p>Histórico de manutenções dos veículos</p>
                </a>

                <a href="gerir_aulas_teoricas.jsp" class="card">
                    <div class="card-icon teoricas">
                        <i class="fa fa-chalkboard"></i>
                    </div>
                    <h3>Aulas Teóricas</h3>
                    <p>Registo de aulas de código e controlo de acesso à condução</p>
                </a>
            </div>
        </div>
    </section>
</body>
</html>
