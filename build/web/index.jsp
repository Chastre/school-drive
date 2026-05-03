<%-- 
    Document   : index
    Created on : 30/12/2025, 17:09:36
    Author     : pmnch
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="utf-8">
    <title>Drive School - Escola de Condução</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --azul:     #1a3a4d;
            --bordeaux: #800020;
            --gold:     #FFC107;
            --gold2:    #FFB300;
            --branco:   #ffffff;
            --glass:    rgba(255,255,255,0.06);
            --glass-b:  rgba(255,255,255,0.12);
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Work Sans', sans-serif;
            background: linear-gradient(135deg, var(--azul) 0%, var(--bordeaux) 100%);
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
        }

        /* ── TOPBAR ─────────────────────────────────────── */
        .topbar {
            background: rgba(0,0,0,0.45);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255,193,7,0.15);
            padding: 10px 0;
            font-size: 0.88rem;
        }
        .topbar .wrap {
            max-width: 1200px; margin: 0 auto; padding: 0 20px;
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;
        }
        .topbar .item { display: flex; align-items: center; gap: 7px; color: rgba(255,255,255,0.85); }
        .topbar .item i { color: var(--gold); font-size: 0.9rem; }
        .topbar a.item { text-decoration: none; transition: color .2s; }
        .topbar a.item:hover { color: var(--gold); }

        /* ── NAVBAR ─────────────────────────────────────── */
        .navbar {
            background: rgba(0,0,0,0.3);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255,193,7,0.2);
            position: sticky; top: 0; z-index: 999;
        }
        .navbar .wrap {
            max-width: 1200px; margin: 0 auto; padding: 12px 20px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .navbar-brand img { height: 52px; width: auto; filter: drop-shadow(0 0 8px rgba(255,193,7,0.3)); transition: .3s; }
        .navbar-brand img:hover { transform: scale(1.05); filter: drop-shadow(0 0 14px rgba(255,193,7,0.5)); }
        .navbar-menu { display: flex; gap: 28px; align-items: center; }
        .navbar-menu a {
            text-decoration: none; color: white; font-weight: 500; font-size: .95rem;
            padding: 6px 0; border-bottom: 2px solid transparent; transition: all .25s;
        }
        .navbar-menu a:hover { color: var(--gold); border-bottom-color: var(--gold); }
        .btn-inscrever {
            background: linear-gradient(135deg, var(--gold), var(--gold2));
            color: var(--azul) !important; padding: 9px 22px; border-radius: 25px;
            font-weight: 700 !important; display: inline-flex; align-items: center; gap: 7px;
            border-bottom: none !important; box-shadow: 0 4px 14px rgba(255,193,7,.35); transition: all .3s;
        }
        .btn-inscrever:hover { transform: translateY(-2px); box-shadow: 0 7px 22px rgba(255,193,7,.55); }
        .btn-login {
            background: rgba(255,255,255,.1); color: white !important; padding: 9px 22px;
            border-radius: 25px; font-weight: 600 !important;
            border: 2px solid rgba(255,255,255,.3) !important; transition: all .3s;
        }
        .btn-login:hover { background: rgba(255,255,255,.18); border-color: var(--gold) !important; color: var(--gold) !important; }

        /* ── HERO ────────────────────────────────────────── */
        .hero {
            padding: 110px 20px 90px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .hero::before {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse at 50% 0%, rgba(255,193,7,.12) 0%, transparent 65%);
            pointer-events: none;
        }
        .hero h1 {
            font-size: clamp(2.2rem, 5vw, 3.8rem);
            font-weight: 800; line-height: 1.15;
            margin-bottom: 18px;
            text-shadow: 0 4px 20px rgba(0,0,0,.4);
            animation: fadeDown .9s ease both;
        }
        .hero h1 span { color: var(--gold); }
        .hero p {
            font-size: 1.15rem; color: rgba(255,255,255,.88);
            max-width: 640px; margin: 0 auto 40px; line-height: 1.75;
            animation: fadeUp .9s .15s ease both;
        }
        .hero-btns {
            display: flex; gap: 16px; justify-content: center; flex-wrap: wrap;
            animation: fadeIn 1s .3s ease both;
        }
        .hero-btn {
            padding: 14px 36px; border-radius: 30px; text-decoration: none;
            font-weight: 700; font-size: 1rem; display: inline-flex; align-items: center; gap: 9px; transition: all .3s;
        }
        .hero-btn-primary {
            background: linear-gradient(135deg, var(--gold), var(--gold2));
            color: var(--azul); box-shadow: 0 8px 28px rgba(255,193,7,.4);
        }
        .hero-btn-primary:hover { transform: translateY(-3px); box-shadow: 0 14px 38px rgba(255,193,7,.6); }
        .hero-btn-secondary {
            background: rgba(255,255,255,.1); color: white;
            border: 2px solid rgba(255,255,255,.3); backdrop-filter: blur(8px);
        }
        .hero-btn-secondary:hover { background: rgba(255,255,255,.18); border-color: var(--gold); color: var(--gold); }

        /* ── STATS BAR ───────────────────────────────────── */
        .stats-bar {
            background: rgba(0,0,0,.25);
            backdrop-filter: blur(10px);
            border-top: 1px solid rgba(255,193,7,.15);
            border-bottom: 1px solid rgba(255,193,7,.15);
            padding: 28px 20px;
        }
        .stats-bar .wrap {
            max-width: 900px; margin: 0 auto;
            display: flex; justify-content: space-around; align-items: center; flex-wrap: wrap; gap: 20px;
        }
        .stat-item { text-align: center; }
        .stat-item .num { font-size: 2.4rem; font-weight: 800; color: var(--gold); line-height: 1; }
        .stat-item .lbl { font-size: .85rem; color: rgba(255,255,255,.7); margin-top: 4px; text-transform: uppercase; letter-spacing: .8px; }

        /* ── SECÇÕES ─────────────────────────────────────── */
        .section { padding: 80px 20px; }
        .section-dark { background: rgba(0,0,0,.2); }
        .wrap { max-width: 1200px; margin: 0 auto; }
        .section-title { text-align: center; margin-bottom: 55px; }
        .section-title h2 { font-size: 2.2rem; font-weight: 800; color: white; margin-bottom: 12px; }
        .section-title h2 span { color: var(--gold); }
        .section-title p { color: rgba(255,255,255,.75); font-size: 1.05rem; }

        /* ── CARTAS ──────────────────────────────────────── */
        .cartas-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 28px; margin-bottom: 36px;
        }
        .carta-card {
            border-radius: 22px; padding: 44px 38px; position: relative; overflow: hidden;
            transition: transform .3s, box-shadow .3s;
        }
        .carta-card:hover { transform: translateY(-6px); box-shadow: 0 20px 50px rgba(0,0,0,.35); }
        .carta-b {
            background: linear-gradient(145deg, rgba(26,58,77,.95), rgba(26,58,77,.7));
            border: 1px solid rgba(255,193,7,.35);
        }
        .carta-a {
            background: linear-gradient(145deg, rgba(128,0,32,.9), rgba(100,0,25,.7));
            border: 1px solid rgba(255,193,7,.35);
        }
        .carta-card::before {
            content: ''; position: absolute; top: -40px; right: -40px;
            width: 160px; height: 160px; border-radius: 50%;
            background: rgba(255,193,7,.06); pointer-events: none;
        }
        .carta-badge {
            display: inline-block; background: var(--gold); color: var(--azul);
            font-size: .75rem; font-weight: 800; letter-spacing: 1.5px;
            text-transform: uppercase; padding: 5px 14px; border-radius: 20px;
            margin-bottom: 22px;
        }
        .carta-icon { font-size: 3.2rem; color: rgba(255,255,255,.15); margin-bottom: 14px; }
        .carta-card h3 { font-size: 1.6rem; font-weight: 800; color: white; margin-bottom: 12px; }
        .carta-card > p { color: rgba(255,255,255,.78); line-height: 1.7; margin-bottom: 22px; font-size: .97rem; }
        .carta-list { list-style: none; margin-bottom: 28px; display: flex; flex-direction: column; gap: 9px; }
        .carta-list li { display: flex; align-items: center; gap: 10px; color: rgba(255,255,255,.88); font-size: .93rem; }
        .carta-list li i { color: var(--gold); font-size: .85rem; flex-shrink: 0; }
        .carta-btn {
            display: inline-flex; align-items: center; gap: 8px;
            background: linear-gradient(135deg, var(--gold), var(--gold2));
            color: var(--azul); font-weight: 700; padding: 12px 28px;
            border-radius: 25px; text-decoration: none; font-size: .95rem;
            transition: all .3s; box-shadow: 0 5px 18px rgba(255,193,7,.3);
        }
        .carta-btn:hover { transform: translateY(-2px); box-shadow: 0 9px 26px rgba(255,193,7,.5); }
        /* mini vantagens */
        .vantagens-row {
            display: flex; gap: 0; background: rgba(0,0,0,.2); border-radius: 16px;
            border: 1px solid rgba(255,193,7,.15); overflow: hidden;
        }
        .vantagem {
            flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 10px; padding: 22px 16px; text-align: center;
            border-right: 1px solid rgba(255,255,255,.07); transition: background .25s;
        }
        .vantagem:last-child { border-right: none; }
        .vantagem:hover { background: rgba(255,193,7,.07); }
        .vantagem i { font-size: 1.5rem; color: var(--gold); }
        .vantagem span { font-size: .85rem; color: rgba(255,255,255,.75); font-weight: 500; line-height: 1.3; }
        @media (max-width: 700px) {
            .cartas-grid { grid-template-columns: 1fr; }
            .vantagens-row { flex-wrap: wrap; }
            .vantagem { flex: 0 0 50%; border-right: none; border-bottom: 1px solid rgba(255,255,255,.07); }
        }

        /* ── SOBRE ───────────────────────────────────────── */
        .sobre-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 50px; align-items: center;
        }
        .sobre-text h2 { font-size: 2.2rem; font-weight: 800; margin-bottom: 20px; }
        .sobre-text h2 span { color: var(--gold); }
        .sobre-text p { color: rgba(255,255,255,.85); line-height: 1.85; margin-bottom: 16px; font-size: 1rem; }
        .sobre-items { display: flex; flex-direction: column; gap: 14px; margin-top: 24px; }
        .sobre-item { display: flex; align-items: center; gap: 12px; }
        .sobre-item i { color: var(--gold); font-size: 1.1rem; flex-shrink: 0; }
        .sobre-item span { color: rgba(255,255,255,.9); font-size: .95rem; }
        .sobre-visual {
            background: var(--glass); backdrop-filter: blur(10px);
            border: 1px solid rgba(255,193,7,.2); border-radius: 20px; padding: 40px;
            text-align: center;
        }
        .sobre-visual i { font-size: 6rem; color: var(--gold); opacity: .8; }
        .sobre-visual p { color: rgba(255,255,255,.7); margin-top: 16px; font-size: 1rem; line-height: 1.6; }

        /* ── LOCALIZAÇÃO ─────────────────────────────────── */
        .localizacao-grid {
            display: grid; grid-template-columns: 1fr 1.6fr; gap: 30px; align-items: start;
        }
        .info-box {
            background: var(--glass); backdrop-filter: blur(10px);
            border: 1px solid rgba(255,193,7,.2); border-radius: 20px; padding: 35px;
        }
        .info-box h3 { font-size: 1.4rem; font-weight: 700; color: white; margin-bottom: 25px;
            display: flex; align-items: center; gap: 10px; }
        .info-box h3 i { color: var(--gold); }
        .info-row {
            display: flex; align-items: flex-start; gap: 14px; padding: 14px 0;
            border-bottom: 1px solid rgba(255,255,255,.08);
        }
        .info-row:last-child { border-bottom: none; padding-bottom: 0; }
        .info-row .ico {
            width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;
            background: rgba(255,193,7,.15); border: 1px solid rgba(255,193,7,.3);
            display: flex; align-items: center; justify-content: center;
        }
        .info-row .ico i { color: var(--gold); font-size: 1rem; }
        .info-row .txt .label { font-size: .78rem; color: rgba(255,255,255,.5); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 3px; }
        .info-row .txt .val { color: white; font-size: .97rem; font-weight: 500; line-height: 1.4; }
        .info-row .txt a { color: var(--gold); text-decoration: none; }
        .info-row .txt a:hover { text-decoration: underline; }
        .chegar-item { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 10px; }
        .chegar-item:last-child { margin-bottom: 0; }
        .chegar-ico { color: var(--gold); font-size: .85rem; flex-shrink: 0; margin-top: 3px; }
        .chegar-item span { color: rgba(255,255,255,.85); font-size: .9rem; line-height: 1.45; font-weight: 400; }
        .chegar-item span strong { color: white; font-weight: 600; }

        .map-box {
            background: var(--glass); backdrop-filter: blur(10px);
            border: 1px solid rgba(255,193,7,.2); border-radius: 20px;
            overflow: hidden; position: relative;
        }
        .map-box iframe {
            width: 100%; height: 420px; border: none; display: block;
            filter: grayscale(20%) contrast(1.05);
        }
        .map-overlay-label {
            position: absolute; top: 14px; left: 14px;
            background: rgba(26,58,77,.92); backdrop-filter: blur(8px);
            border: 1px solid rgba(255,193,7,.3); border-radius: 10px;
            padding: 8px 14px; display: flex; align-items: center; gap: 8px;
            font-size: .85rem; font-weight: 600; color: white; pointer-events: none;
        }
        .map-overlay-label i { color: var(--gold); }

        /* ── FOOTER ──────────────────────────────────────── */
        .footer {
            background: rgba(0,0,0,.45);
            backdrop-filter: blur(12px);
            border-top: 1px solid rgba(255,193,7,.2);
            padding: 36px 20px; text-align: center;
        }
        .footer-links { display: flex; gap: 28px; justify-content: center; margin-bottom: 16px; flex-wrap: wrap; }
        .footer-links a { color: rgba(255,255,255,.65); text-decoration: none; font-size: .92rem; transition: color .2s; }
        .footer-links a:hover { color: var(--gold); }
        .footer p { color: rgba(255,255,255,.45); font-size: .85rem; }

        /* ── ANIMAÇÕES ───────────────────────────────────── */
        @keyframes fadeDown { from { opacity:0; transform:translateY(-28px); } to { opacity:1; transform:translateY(0); } }
        @keyframes fadeUp   { from { opacity:0; transform:translateY(28px);  } to { opacity:1; transform:translateY(0); } }
        @keyframes fadeIn   { from { opacity:0; } to { opacity:1; } }

        /* ── RESPONSIVE ──────────────────────────────────── */
        @media (max-width: 900px) {
            .sobre-grid, .localizacao-grid { grid-template-columns: 1fr; }
            .navbar-menu { gap: 14px; }
        }
        @media (max-width: 640px) {
            .navbar-menu a:not(.btn-inscrever):not(.btn-login) { display: none; }
            .topbar .item:nth-child(3), .topbar .item:nth-child(4) { display: none; }
            .hero-btns { flex-direction: column; align-items: stretch; }
            .hero-btn { justify-content: center; }
        }
    </style>
</head>
<body>

    <!-- TOPBAR -->
    <div class="topbar">
        <div class="wrap">
            <a href="#localizacao" class="item">
                <i class="fa fa-map-marker-alt"></i>
                <span>Av. Joaquim Neves dos Santos 697, Matosinhos</span>
            </a>
            <div style="display:flex;gap:24px;flex-wrap:wrap;">
                <a href="tel:+351220123456" class="item">
                    <i class="fa fa-phone-alt"></i>
                    <span>934 701 827</span>
                </a>
                <span class="item">
                    <i class="fa fa-clock"></i>
                    <span>Seg–Sex: 09h–19h</span>
                </span>
            </div>
        </div>
    </div>

    <!-- NAVBAR -->
    <nav class="navbar">
        <div class="wrap">
            <a href="index.jsp" class="navbar-brand">
                <img src="image/logo_mini.png" alt="Drive School">
            </a>
            <div class="navbar-menu">
                <a href="#inicio">Início</a>
                <a href="#funcionalidades">Funcionalidades</a>
                <a href="#sobre">Sobre</a>
                <a href="#localizacao">Localização</a>
                <a href="registar_aluno.jsp" class="btn-inscrever">
                    <i class="fa fa-user-plus"></i>Inscrever-me
                </a>
                <a href="login.jsp" class="btn-login">
                    <i class="fa fa-sign-in-alt"></i>Entrar
                </a>
            </div>
        </div>
    </nav>

    <!-- HERO -->
    <section class="hero" id="inicio">
        <h1>Bem-vindo à<br><span>Drive School</span></h1>
        <p>A tua escola de condução em Matosinhos. Instrutores experientes, veículos modernos e a melhor preparação para o teu exame.</p>
        <div class="hero-btns">
            <a href="registar_aluno.jsp" class="hero-btn hero-btn-primary">
                <i class="fa fa-user-plus"></i>Inscrever-me Agora
            </a>
            <a href="login.jsp" class="hero-btn hero-btn-secondary">
                <i class="fa fa-sign-in-alt"></i>Já tenho conta
            </a>
        </div>
    </section>

    <!-- STATS -->
    <div class="stats-bar">
        <div class="wrap">
            <div class="stat-item">
                <div class="num">500+</div>
                <div class="lbl">Alunos Formados</div>
            </div>
            <div class="stat-item">
                <div class="num">95%</div>
                <div class="lbl">Taxa de Aprovação</div>
            </div>
            <div class="stat-item">
                <div class="num">10+</div>
                <div class="lbl">Anos de Experiência</div>
            </div>
            <div class="stat-item">
                <div class="num">2</div>
                <div class="lbl">Categorias Disponíveis</div>
            </div>
        </div>
    </div>

    <!-- FUNCIONALIDADES -->
    <section class="section" id="funcionalidades">
        <div class="wrap">
            <div class="section-title">
                <h2>O que <span>oferecemos</span></h2>
                <p>Duas categorias, um objetivo: tirares a carta com confiança</p>
            </div>

            <!-- CARTAS EM DESTAQUE -->
            <div class="cartas-grid">
                <div class="carta-card carta-b">
                    <div class="carta-badge">Categoria B</div>
                    <div class="carta-icon"><i class="fa fa-car"></i></div>
                    <h3>Carta de Automóvel</h3>
                    <p>A carta mais escolhida para o dia a dia. Formação teórica e prática completa para conduzir ligeiros de passageiros.</p>
                    <ul class="carta-list">
                        <li><i class="fa fa-check"></i> Aulas teóricas incluídas</li>
                        <li><i class="fa fa-check"></i> Aulas práticas com instrutor</li>
                        <li><i class="fa fa-check"></i> Preparação para exame IMT</li>
                        <li><i class="fa fa-check"></i> Pagamento a pronto ou parcelado</li>
                    </ul>
                    <a href="registar_aluno.jsp" class="carta-btn">Inscrever-me</a>
                </div>

                <div class="carta-card carta-a">
                    <div class="carta-badge">Categoria A</div>
                    <div class="carta-icon"><i class="fa fa-motorcycle"></i></div>
                    <h3>Carta de Motociclo</h3>
                    <p>Para quem quer a liberdade de andar de moto. Formação adaptada desde iniciantes até condutores experientes.</p>
                    <ul class="carta-list">
                        <li><i class="fa fa-check"></i> Categorias A1, A2 e A</li>
                        <li><i class="fa fa-check"></i> Pistas de treino equipadas</li>
                        <li><i class="fa fa-check"></i> Preparação para exame IMT</li>
                        <li><i class="fa fa-check"></i> Pagamento a pronto ou parcelado</li>
                    </ul>
                    <a href="registar_aluno.jsp" class="carta-btn">Inscrever-me</a>
                </div>
            </div>

            <!-- MINI VANTAGENS -->
            <div class="vantagens-row">
                <div class="vantagem">
                    <i class="fa fa-calendar-check"></i>
                    <span>Agendamento online 24/7</span>
                </div>
                <div class="vantagem">
                    <i class="fa fa-money-bill-wave"></i>
                    <span>Pagamento flexível</span>
                </div>
                <div class="vantagem">
                    <i class="fa fa-car-side"></i>
                    <span>Veículos modernos</span>
                </div>
                <div class="vantagem">
                    <i class="fa fa-trophy"></i>
                    <span>95% taxa de aprovação</span>
                </div>
            </div>
        </div>
    </section>

    <!-- SOBRE -->
    <section class="section section-dark" id="sobre">
        <div class="wrap">
            <div class="sobre-grid">
                <div class="sobre-text">
                    <h2>Sobre a <span>Drive School</span></h2>
                    <p>Somos uma escola de condução com mais de 10 anos de experiência em Matosinhos, dedicados a formar condutores responsáveis, seguros e preparados para os desafios da estrada.</p>
                    <p>A nossa plataforma digital permite que alunos, instrutores e administração gerem tudo de forma simples e transparente.</p>
                    <div class="sobre-items">
                        <div class="sobre-item">
                            <i class="fa fa-check-circle"></i>
                            <span>Carta de Condução Categoria A (Motociclos)</span>
                        </div>
                        <div class="sobre-item">
                            <i class="fa fa-check-circle"></i>
                            <span>Carta de Condução Categoria B (Automóveis)</span>
                        </div>
                        <div class="sobre-item">
                            <i class="fa fa-check-circle"></i>
                            <span>Aulas individuais com instrutor dedicado</span>
                        </div>
                        <div class="sobre-item">
                            <i class="fa fa-check-circle"></i>
                            <span>Plataforma online acessível 24/7</span>
                        </div>
                    </div>
                </div>
                <div class="sobre-visual">
                    <i class="fa fa-graduation-cap"></i>
                    <p>Mais de 500 alunos formados com sucesso nos últimos anos, com uma das maiores taxas de aprovação da região do Porto.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- LOCALIZAÇÃO -->
    <section class="section" id="localizacao">
        <div class="wrap">
            <div class="section-title">
                <h2>A nossa <span>Localização</span></h2>
                <p>Encontra-nos facilmente em Matosinhos</p>
            </div>
            <div class="localizacao-grid">

                <!-- INFO -->
                <div class="info-box">
                    <h3><i class="fa fa-map-marker-alt"></i> Informações</h3>

                    <div class="info-row">
                        <div class="ico"><i class="fa fa-map-marker-alt"></i></div>
                        <div class="txt">
                            <div class="label">Morada</div>
                            <div class="val">Av. Joaquim Neves dos Santos 697<br>4460-125 Matosinhos</div>
                        </div>
                    </div>

                    <div class="info-row">
                        <div class="ico"><i class="fa fa-phone-alt"></i></div>
                        <div class="txt">
                            <div class="label">Telefone</div>
                            <div class="val"><a href="tel:+351934701827">934 701 827</a></div>
                        </div>
                    </div>

                    <div class="info-row">
                        <div class="ico"><i class="fa fa-envelope"></i></div>
                        <div class="txt">
                            <div class="label">Email</div>
                            <div class="val"><a href="mailto:driveschool@gmail.com">driveschool@gmail.com</a></div>
                        </div>
                    </div>

                    <div class="info-row">
                        <div class="ico"><i class="fa fa-clock"></i></div>
                        <div class="txt">
                            <div class="label">Horário de Atendimento</div>
                            <div class="val">Segunda a Sexta: 09h – 19h</div>
                        </div>
                    </div>

                    <div class="info-row">
                        <div class="ico"><i class="fa fa-directions"></i></div>
                        <div class="txt">
                            <div class="label">Como chegar</div>
                            <div class="val">
                                <div class="chegar-item">
                                    <i class="fa fa-subway chegar-ico"></i>
                                    <span><strong>Metro:</strong> Linha azul (Senhor de Matosintos) - Estação <strong>Vasco da Gama</strong>, ~10 min a pé</span>
                                </div>
                                <div class="chegar-item">
                                    <i class="fa fa-bus chegar-ico"></i>
                                    <span><strong>Autocarro:</strong> Linhas 5002, 5005, 5010, 5011, 507, 5013, 5014, 5018 — Paragem <strong>Av. Joaquim Neves dos Santos</strong> (mesmo à porta)</span>
                                </div>
                                <div class="chegar-item">
                                    <i class="fa fa-car chegar-ico"></i>
                                    <span><strong>Carro:</strong> Saída A28 Matosinhos / Porto de Leixões, seguir pela N12 em direção a Guifões</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MAPA -->
                <div class="map-box">
                    <div class="map-overlay-label">
                        <i class="fa fa-map-marker-alt"></i>
                        Drive School – Matosinhos
                    </div>
                    <iframe
                        src="https://maps.google.com/maps?q=Av.+Joaquim+Neves+dos+Santos+697,+4460-125+Matosinhos,+Portugal&output=embed&z=17&hl=pt"
                        allowfullscreen="" loading="lazy"
                        referrerpolicy="no-referrer-when-downgrade">
                    </iframe>
                </div>
            </div>


        </div>
    </section>

    <!-- FOOTER -->
    <footer class="footer">
        <div class="wrap">
            <div class="footer-links">
                <a href="#inicio">Início</a>
                <a href="#funcionalidades">Funcionalidades</a>
                <a href="#sobre">Sobre</a>
                <a href="#localizacao">Localização</a>
                <a href="login.jsp">Login</a>
                <a href="registar_aluno.jsp">Inscrição</a>
            </div>
            <p>&copy; 2026 Drive School – Escola de Condução, Matosinhos. Todos os direitos reservados.</p>
        </div>
    </footer>

</body>
</html>
