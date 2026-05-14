from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import re
import requests as req

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# =========================
# 🔑 API KEYS
# =========================
IGNAV_API_KEY = "ignav_7BBJ0sB49xeCLUnSkQj49zAC3evalVAD"
LITEAPI_KEY = "sand_44608595-e7d3-4c5c-8a08-d3a1b2e48de4"
UNSPLASH_ACCESS_KEY = "iIG7l5pTcBuKTH_aJ1BdaO8rsfizJPaFPxVo3KNHY-A"

USD_A_COP = 4200

# =========================
# 🔥 NUEVO: MAPA DE DESTINOS SIN AEROPUERTO
# ciudad_sin_aeropuerto → info de acceso real
# =========================
DESTINOS_SIN_AEROPUERTO = {
    "girardot": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Bogotá (BOG)",
        "codigo_iata_cercano": "BOG",
        "distancia_km": 132,
        "tiempo_terrestre": "2h 30min",
        "transporte": [
            {"tipo": "Bus", "descripcion": "Terminal de Transporte de Bogotá → Girardot. Empresas: Coomotor, Flota Magdalena.", "precio_aprox": "$25.000 - $40.000 COP", "duracion": "2h 30min"},
            {"tipo": "Carro particular", "descripcion": "Por la autopista Bogotá-Girardot (peaje aprox. $15.000).", "precio_aprox": "$15.000 en peajes", "duracion": "2h"},
        ],
        "instrucciones": "Vuela a Bogotá (El Dorado), luego toma un bus en la Terminal de Transportes hacia Girardot. Salen cada 30 minutos.",
        "nota": "Girardot no cuenta con aeropuerto comercial activo. El acceso más cómodo es por carretera desde Bogotá."
    },
    "villa de leyva": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Bogotá (BOG)",
        "codigo_iata_cercano": "BOG",
        "distancia_km": 165,
        "tiempo_terrestre": "3h",
        "transporte": [
            {"tipo": "Bus", "descripcion": "Terminal Bogotá → Tunja, luego Tunja → Villa de Leyva.", "precio_aprox": "$35.000 - $50.000 COP", "duracion": "3h"},
            {"tipo": "Carro particular", "descripcion": "Por la autopista Bogotá-Tunja-Villa de Leyva.", "precio_aprox": "$20.000 en peajes", "duracion": "2h 45min"},
        ],
        "instrucciones": "Vuela a Bogotá (El Dorado), toma un bus a Tunja y desde allí hay buses cada hora hacia Villa de Leyva.",
        "nota": "Villa de Leyva no tiene aeropuerto. El trayecto desde Bogotá es parte de la experiencia turística."
    },
    "salento": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Pereira (PEI)",
        "codigo_iata_cercano": "PEI",
        "distancia_km": 55,
        "tiempo_terrestre": "1h 20min",
        "transporte": [
            {"tipo": "Bus", "descripcion": "Terminal de Pereira → Armenia, bajada en Salento.", "precio_aprox": "$15.000 - $20.000 COP", "duracion": "1h 20min"},
            {"tipo": "Taxi/Uber", "descripcion": "Directo desde el aeropuerto de Pereira a Salento.", "precio_aprox": "$50.000 - $70.000 COP", "duracion": "1h"},
        ],
        "instrucciones": "Vuela a Pereira (Matecaña), luego toma un taxi o bus hasta Salento. Es el ingreso al Eje Cafetero.",
        "nota": "Salento no tiene aeropuerto pero está muy cerca de Pereira y Armenia."
    },
    "tayrona": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Santa Marta (SMR)",
        "codigo_iata_cercano": "SMR",
        "distancia_km": 35,
        "tiempo_terrestre": "45min",
        "transporte": [
            {"tipo": "Bus/Colectivo", "descripcion": "Desde Santa Marta hacia El Zaino (entrada al parque).", "precio_aprox": "$8.000 - $15.000 COP", "duracion": "45min"},
            {"tipo": "Taxi", "descripcion": "Directo desde el aeropuerto de Santa Marta a la entrada del parque.", "precio_aprox": "$40.000 - $60.000 COP", "duracion": "40min"},
        ],
        "instrucciones": "Vuela a Santa Marta, luego toma un bus o colectivo hacia El Zaino, la entrada principal del Parque Tayrona.",
        "nota": "El Parque Tayrona no tiene aeropuerto. Santa Marta es la puerta de entrada más cercana."
    },
    "san gil": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Bucaramanga (BGA)",
        "codigo_iata_cercano": "BGA",
        "distancia_km": 100,
        "tiempo_terrestre": "2h",
        "transporte": [
            {"tipo": "Bus", "descripcion": "Terminal de Bucaramanga → San Gil. Empresas: Cotrans, Berlinas.", "precio_aprox": "$25.000 - $35.000 COP", "duracion": "2h"},
            {"tipo": "Carro particular", "descripcion": "Por la troncal del Magdalena Medio.", "precio_aprox": "$15.000 en peajes", "duracion": "1h 45min"},
        ],
        "instrucciones": "Vuela a Bucaramanga (Palonegro), luego toma un bus hacia San Gil desde el terminal.",
        "nota": "San Gil, capital de aventura de Colombia, no tiene aeropuerto propio."
    },
    "leticia": {
        "tiene_aeropuerto": True,
        "codigo_iata": "LET",
        "nota": "Leticia tiene aeropuerto propio (Alfredo Vásquez Cobo). Solo accesible por avión o por río desde Brasil/Perú."
    },
    "nuquí": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Quibdó (UIB) o vuelo charter",
        "codigo_iata_cercano": "UIB",
        "distancia_km": 200,
        "tiempo_terrestre": "No hay carretera",
        "transporte": [
            {"tipo": "Vuelo charter/pequeño", "descripcion": "Desde Medellín o Quibdó en avioneta (Satena u operadores locales).", "precio_aprox": "$300.000 - $500.000 COP", "duracion": "45min en avioneta"},
            {"tipo": "Lancha", "descripcion": "Desde Bahía Solano si llegas por allá primero.", "precio_aprox": "$80.000 - $120.000 COP", "duracion": "3h"},
        ],
        "instrucciones": "Nuquí solo es accesible por avioneta o lancha. Busca vuelos en Satena o aerolíneas regionales desde Medellín.",
        "nota": "Nuquí no tiene carretera. Es uno de los destinos más remotos e impresionantes del Pacífico colombiano."
    },
    "nuqui": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Quibdó (UIB) o vuelo charter",
        "codigo_iata_cercano": "UIB",
        "distancia_km": 200,
        "tiempo_terrestre": "No hay carretera",
        "transporte": [
            {"tipo": "Vuelo charter/pequeño", "descripcion": "Desde Medellín o Quibdó en avioneta (Satena u operadores locales).", "precio_aprox": "$300.000 - $500.000 COP", "duracion": "45min en avioneta"},
            {"tipo": "Lancha", "descripcion": "Desde Bahía Solano.", "precio_aprox": "$80.000 - $120.000 COP", "duracion": "3h"},
        ],
        "instrucciones": "Nuquí solo es accesible por avioneta o lancha. Busca vuelos en Satena desde Medellín.",
        "nota": "Nuquí no tiene carretera. Es uno de los destinos más remotos e impresionantes del Pacífico colombiano."
    },
    "mompox": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Corozal (CZU) o Cartagena (CTG)",
        "codigo_iata_cercano": "CTG",
        "distancia_km": 250,
        "tiempo_terrestre": "5h",
        "transporte": [
            {"tipo": "Bus + Ferry", "descripcion": "Desde Cartagena en bus hasta Magangué, luego lancha a Mompox.", "precio_aprox": "$70.000 - $100.000 COP", "duracion": "5h total"},
            {"tipo": "Bus directo", "descripcion": "Desde Barranquilla o Cartagena, empresas como Unitransco.", "precio_aprox": "$60.000 - $80.000 COP", "duracion": "5h"},
        ],
        "instrucciones": "Vuela a Cartagena, luego toma un bus hacia Magangué y desde allí una lancha al Brazo de Mompox. El viaje hace parte de la magia.",
        "nota": "Mompox no tiene aeropuerto. La ruta fluvial desde Magangué es la más pintoresca."
    },
    "bahia solano": {
        "tiene_aeropuerto": True,
        "codigo_iata": "BSC",
        "nota": "Bahía Solano tiene pequeño aeropuerto. Satena opera vuelos desde Medellín."
    },
    "capurganá": {
        "tiene_aeropuerto": False,
        "aeropuerto_cercano": "Acandí (pista pequeña) o Medellín (MDE)",
        "codigo_iata_cercano": "MDE",
        "distancia_km": 400,
        "tiempo_terrestre": "No hay carretera",
        "transporte": [
            {"tipo": "Lancha desde Turbo", "descripcion": "Vuela a Medellín/Carepa, bus hasta Turbo, luego lancha a Capurganá.", "precio_aprox": "$80.000 - $120.000 COP la lancha", "duracion": "2h de lancha"},
            {"tipo": "Avioneta", "descripcion": "Vuelos chárter desde Medellín/Carepa (Aeropuerto Los Cedros).", "precio_aprox": "$250.000 - $400.000 COP", "duracion": "40min"},
        ],
        "instrucciones": "Vuela a Medellín o Carepa, luego bus a Turbo y lancha a Capurganá. Destino paradisíaco sin carretera.",
        "nota": "Capurganá no tiene carretera ni aeropuerto comercial. La aventura empieza en el viaje."
    },
}

# Mapa IATA para destinos CON aeropuerto
CODIGOS_IATA = {
    "cartagena": "CTG",
    "san andrés": "ADZ",
    "san andres": "ADZ",
    "medellín": "MDE",
    "medellin": "MDE",
    "santa marta": "SMR",
    "bogotá": "BOG",
    "bogota": "BOG",
    "cali": "CLO",
    "leticia": "LET",
    "manizales": "MZL",
    "pereira": "PEI",
    "bucaramanga": "BGA",
    "barranquilla": "BAQ",
    "pasto": "PSO",
    "cucuta": "CUC",
    "cúcuta": "CUC",
    "armenia": "AXM",
    "neiva": "NVA",
    "villavicencio": "VVC",
    "punta cana": "PUJ",
    "cancun": "CUN",
    "cancún": "CUN",
    "miami": "MIA",
    "paris": "CDG",
    "madrid": "MAD",
    "new york": "JFK",
    "nueva york": "JFK",
    "london": "LHR",
    "londres": "LHR",
    "lima": "LIM",
    "quito": "UIO",
    "ciudad de mexico": "MEX",
    "ciudad de méxico": "MEX",
    "rio de janeiro": "GIG",
    "buenos aires": "EZE",
    "panama": "PTY",
    "panamá": "PTY",
}

# =========================
# 📸 CACHE DE IMÁGENES
# =========================
_imagen_cache = {}
_imagenes_destino_cache = {}

# =========================
# 🛫 IMÁGENES REALES POR AEROLÍNEA
# =========================
IMAGENES_AEROLINEAS_MULTIPLES = {
    "avianca": [
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
    ],
    "latam": [
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
    ],
    "wingo": [
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
    ],
    "copa": [
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
    ],
    "jetsmart": [
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
    ],
    "easy fly": [
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
    ],
    "satena": [
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
    ],
    "american": [
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
    ],
    "united": [
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
    ],
    "delta": [
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
    ],
    "iberia": [
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
    ],
    "air france": [
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
    ],
    "lufthansa": [
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
    ],
    "emirates": [
        "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=1200&q=80",
        "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
    ],
    "default": [
        "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=1200&q=80",
        "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=1200&q=80",
        "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=1200&q=80",
        "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=1200&q=80",
        "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1200&q=80",
        "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=1200&q=80",
        "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=1200&q=80",
        "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=1200&q=80",
        "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=1200&q=80",
    ],
}

IMAGENES_AEROLINEAS = {
    "avianca": "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800",
    "latam": "https://images.unsplash.com/photo-1569629743817-70d8db6c323b?w=800",
    "jetsmart": "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=800",
    "copa": "https://images.unsplash.com/photo-1583202736561-d1ef2a7a19c6?w=800",
    "wingo": "https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=800",
    "american": "https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=800",
    "united": "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=800",
    "delta": "https://images.unsplash.com/photo-1540962351504-03099e0a754b?w=800",
    "iberia": "https://images.unsplash.com/photo-1551197072-c7ce4a887334?w=800",
    "air france": "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=800",
    "lufthansa": "https://images.unsplash.com/photo-1559269397-46cef0df5c7e?w=800",
    "emirates": "https://images.unsplash.com/photo-1534481016308-0fca71578ae5?w=800",
    "easy fly": "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=800",
    "satena": "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=800",
    "default": "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800",
}

IMAGENES_CIUDADES_FALLBACK = {
    "cartagena": [
        "https://images.unsplash.com/photo-1583997052103-b4a1cb974ce5?w=800",
        "https://images.unsplash.com/photo-1576075272913-df1d6ec0e4df?w=800",
        "https://images.unsplash.com/photo-1568502806300-14777d78b3fb?w=800",
        "https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800",
        "https://images.unsplash.com/photo-1590736704728-f4730bb30770?w=800",
        "https://images.unsplash.com/photo-1599484668312-cb06053b6ab8?w=800",
    ],
    "medellin": [
        "https://images.unsplash.com/photo-1599413987323-b2b8c0d7d9c8?w=800",
        "https://images.unsplash.com/photo-1581803118522-7b72a50f7e9f?w=800",
        "https://images.unsplash.com/photo-1562516155-e0d1d36a3de5?w=800",
        "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
        "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800",
        "https://images.unsplash.com/photo-1595781572981-d63151b232ed?w=800",
    ],
    "medellín": [
        "https://images.unsplash.com/photo-1599413987323-b2b8c0d7d9c8?w=800",
        "https://images.unsplash.com/photo-1581803118522-7b72a50f7e9f?w=800",
        "https://images.unsplash.com/photo-1562516155-e0d1d36a3de5?w=800",
        "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
        "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800",
        "https://images.unsplash.com/photo-1595781572981-d63151b232ed?w=800",
    ],
    "san andres": [
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=800",
        "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=800",
        "https://images.unsplash.com/photo-1490604001847-b712b0c2f967?w=800",
    ],
    "san andrés": [
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=800",
        "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=800",
        "https://images.unsplash.com/photo-1490604001847-b712b0c2f967?w=800",
    ],
    "santa marta": [
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
        "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800",
        "https://images.unsplash.com/photo-1511884642898-4c92249e20b6?w=800",
        "https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=800",
        "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800",
        "https://images.unsplash.com/photo-1552733407-5d5c46c3bb3b?w=800",
    ],
    "punta cana": [
        "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800",
        "https://images.unsplash.com/photo-1570737209810-87a8e7245f88?w=800",
        "https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?w=800",
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800",
    ],
    "bogota": [
        "https://images.unsplash.com/photo-1538683261-2b08a9cdd5ab?w=800",
        "https://images.unsplash.com/photo-1591981853959-26b6b3cf1bc4?w=800",
        "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800",
        "https://images.unsplash.com/photo-1582738411706-bfc8e691d1c2?w=800",
        "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800",
        "https://images.unsplash.com/photo-1562516155-e0d1d36a3de5?w=800",
    ],
    "bogotá": [
        "https://images.unsplash.com/photo-1538683261-2b08a9cdd5ab?w=800",
        "https://images.unsplash.com/photo-1591981853959-26b6b3cf1bc4?w=800",
        "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800",
        "https://images.unsplash.com/photo-1582738411706-bfc8e691d1c2?w=800",
        "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800",
        "https://images.unsplash.com/photo-1562516155-e0d1d36a3de5?w=800",
    ],
    "cali": [
        "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
        "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800",
        "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800",
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
    ],
    "miami": [
        "https://images.unsplash.com/photo-1514214246283-d427a95c5d2f?w=800",
        "https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?w=800",
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
        "https://images.unsplash.com/photo-1570737209810-87a8e7245f88?w=800",
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
    ],
    "paris": [
        "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800",
        "https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800",
        "https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800",
        "https://images.unsplash.com/photo-1431274172761-fca41d930114?w=800",
        "https://images.unsplash.com/photo-1471623320832-752e8bbf8413?w=800",
        "https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=800",
    ],
    "madrid": [
        "https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=800",
        "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800",
        "https://images.unsplash.com/photo-1558642084-fd07fae5282e?w=800",
        "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
        "https://images.unsplash.com/photo-1571406252241-db0280bd36cd?w=800",
        "https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf?w=800",
    ],
    "cancun": [
        "https://images.unsplash.com/photo-1510097467424-192d713fd8b2?w=800",
        "https://images.unsplash.com/photo-1570737209810-87a8e7245f88?w=800",
        "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800",
        "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800",
    ],
    "default": [
        "https://images.unsplash.com/photo-1488085061387-422e29b40080?w=800",
        "https://images.unsplash.com/photo-1503220317375-aaad61436b1b?w=800",
        "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800",
        "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800",
        "https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=800",
        "https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=800",
    ],
}

# =========================
# 🔥 CONEXIÓN MYSQL
# =========================
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "unix_travel"
}

def get_db():
    return mysql.connector.connect(**db_config)

def usd_a_cop(cantidad_usd):
    try:
        cop = float(cantidad_usd) * USD_A_COP
        return f"${cop:,.0f} COP"
    except:
        return "$0 COP"

def formatear_cop(cantidad):
    try:
        return f"${float(cantidad):,.0f} COP"
    except:
        return "$0 COP"

def obtener_imagen_unsplash(query, fallback="travel"):
    if query in _imagen_cache:
        return _imagen_cache[query]
    try:
        response = req.get(
            "https://api.unsplash.com/search/photos",
            params={"query": query, "per_page": 1, "orientation": "landscape", "client_id": UNSPLASH_ACCESS_KEY},
            timeout=5
        )
        if response.status_code == 200:
            results = response.json().get("results", [])
            if results:
                url = results[0]["urls"]["regular"]
                _imagen_cache[query] = url
                return url
    except Exception as e:
        print(f"⚠️ Unsplash error: {e}")
    ciudad_key = fallback.lower()
    fallback_imgs = IMAGENES_CIUDADES_FALLBACK.get(ciudad_key, IMAGENES_CIUDADES_FALLBACK["default"])
    url = fallback_imgs[0]
    _imagen_cache[query] = url
    return url

def obtener_imagenes_unsplash_multiples(query, cantidad=6, fallback="travel"):
    cache_key = f"{query}__{cantidad}"
    if cache_key in _imagenes_destino_cache:
        return _imagenes_destino_cache[cache_key]
    try:
        response = req.get(
            "https://api.unsplash.com/search/photos",
            params={"query": query, "per_page": cantidad, "orientation": "landscape", "client_id": UNSPLASH_ACCESS_KEY},
            timeout=8
        )
        if response.status_code == 200:
            results = response.json().get("results", [])
            if results:
                urls = [r["urls"]["regular"] for r in results]
                _imagenes_destino_cache[cache_key] = urls
                return urls
    except Exception as e:
        print(f"⚠️ Unsplash múltiples error: {e}")
    ciudad_key = fallback.lower()
    fallback_imgs = IMAGENES_CIUDADES_FALLBACK.get(ciudad_key, IMAGENES_CIUDADES_FALLBACK["default"])
    _imagenes_destino_cache[cache_key] = fallback_imgs
    return fallback_imgs

def obtener_imagen_aerolinea(aerolinea):
    aerolinea_lower = aerolinea.lower()
    for key, url in IMAGENES_AEROLINEAS.items():
        if key in aerolinea_lower:
            return url
    return IMAGENES_AEROLINEAS["default"]

def obtener_imagenes_aerolinea_multiples(aerolinea):
    aerolinea_lower = aerolinea.lower()
    for key, urls in IMAGENES_AEROLINEAS_MULTIPLES.items():
        if key in aerolinea_lower:
            return urls
    return IMAGENES_AEROLINEAS_MULTIPLES["default"]

def obtener_imagen_ciudad_fallback(ciudad):
    ciudad_key = ciudad.lower()
    imgs = IMAGENES_CIUDADES_FALLBACK.get(ciudad_key, IMAGENES_CIUDADES_FALLBACK["default"])
    return imgs[0]

# =========================
# 🔥 CREAR TABLAS
# =========================
def crear_tablas():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuario (
            cedula VARCHAR(50) PRIMARY KEY,
            nombre VARCHAR(100),
            apellidos VARCHAR(100),
            email VARCHAR(100),
            `contraseña` VARCHAR(255),
            telefono VARCHAR(20),
            tipo_usuario VARCHAR(20) DEFAULT 'cliente',
            foto_perfil TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS destinos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(255),
            descripcion TEXT,
            precio VARCHAR(50),
            imagen TEXT,
            categoria VARCHAR(50),
            precio_por_persona VARCHAR(50),
            incluye TEXT,
            duracion VARCHAR(50),
            codigo_iata VARCHAR(10)
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS hoteles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(255),
            descripcion TEXT,
            precio_noche VARCHAR(50),
            imagen TEXT,
            destino VARCHAR(255),
            estrellas INT DEFAULT 3,
            tipo_habitacion VARCHAR(100),
            incluye_desayuno BOOLEAN DEFAULT FALSE,
            capacidad INT DEFAULT 2
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS vuelos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            origen VARCHAR(255),
            destino VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT,
            aerolinea VARCHAR(255),
            duracion VARCHAR(50),
            numero_vuelo VARCHAR(50),
            hora_salida VARCHAR(20),
            hora_llegada VARCHAR(20),
            clase VARCHAR(50) DEFAULT 'economica',
            precio_por_persona VARCHAR(50)
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tours (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(255),
            descripcion TEXT,
            precio VARCHAR(50),
            imagen TEXT,
            destino VARCHAR(255),
            duracion VARCHAR(50),
            punto_encuentro VARCHAR(255),
            cupo_maximo INT DEFAULT 20,
            incluye TEXT,
            precio_por_persona VARCHAR(50)
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS carrito (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_cedula VARCHAR(50),
            nombre_producto VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT,
            fecha_ida DATE,
            fecha_vuelta DATE,
            personas INT DEFAULT 1,
            tipo VARCHAR(50) DEFAULT 'destino',
            precio_total VARCHAR(50)
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS favoritos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_cedula VARCHAR(50),
            nombre_producto VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS compras (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_cedula VARCHAR(50),
            nombre_producto VARCHAR(255),
            precio VARCHAR(50),
            imagen TEXT,
            fecha_ida DATE,
            fecha_vuelta DATE,
            personas INT DEFAULT 1,
            tipo VARCHAR(50) DEFAULT 'destino',
            precio_total VARCHAR(50),
            fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS solicitudes_edicion (
            id INT AUTO_INCREMENT PRIMARY KEY,
            compra_id INT,
            usuario_cedula VARCHAR(50),
            fecha_ida_nueva DATE,
            fecha_vuelta_nueva DATE,
            personas_nueva INT,
            motivo TEXT,
            estado VARCHAR(20) DEFAULT 'pendiente',
            fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fecha_respuesta TIMESTAMP NULL,
            respuesta_admin TEXT
        )
    """)
    db.commit()

    migraciones = [
        "ALTER TABLE carrito ADD COLUMN fecha_ida DATE",
        "ALTER TABLE carrito ADD COLUMN fecha_vuelta DATE",
        "ALTER TABLE carrito ADD COLUMN personas INT DEFAULT 1",
        "ALTER TABLE carrito ADD COLUMN tipo VARCHAR(50) DEFAULT 'destino'",
        "ALTER TABLE carrito ADD COLUMN precio_total VARCHAR(50)",
        "ALTER TABLE compras ADD COLUMN tipo VARCHAR(50) DEFAULT 'destino'",
        "ALTER TABLE compras ADD COLUMN precio_total VARCHAR(50)",
        "ALTER TABLE vuelos ADD COLUMN numero_vuelo VARCHAR(50)",
        "ALTER TABLE vuelos ADD COLUMN hora_salida VARCHAR(20)",
        "ALTER TABLE vuelos ADD COLUMN hora_llegada VARCHAR(20)",
        "ALTER TABLE vuelos ADD COLUMN clase VARCHAR(50) DEFAULT 'economica'",
        "ALTER TABLE vuelos ADD COLUMN precio_por_persona VARCHAR(50)",
        "ALTER TABLE hoteles ADD COLUMN tipo_habitacion VARCHAR(100)",
        "ALTER TABLE hoteles ADD COLUMN incluye_desayuno BOOLEAN DEFAULT FALSE",
        "ALTER TABLE hoteles ADD COLUMN capacidad INT DEFAULT 2",
        "ALTER TABLE tours ADD COLUMN punto_encuentro VARCHAR(255)",
        "ALTER TABLE tours ADD COLUMN cupo_maximo INT DEFAULT 20",
        "ALTER TABLE tours ADD COLUMN incluye TEXT",
        "ALTER TABLE tours ADD COLUMN precio_por_persona VARCHAR(50)",
        "ALTER TABLE destinos ADD COLUMN precio_por_persona VARCHAR(50)",
        "ALTER TABLE destinos ADD COLUMN incluye TEXT",
        "ALTER TABLE destinos ADD COLUMN duracion VARCHAR(50)",
        "ALTER TABLE destinos ADD COLUMN codigo_iata VARCHAR(10)",
        "ALTER TABLE usuario ADD COLUMN foto_perfil TEXT",
        # 🔥 NUEVAS COLUMNAS PARA DESTINOS SIN AEROPUERTO
        "ALTER TABLE destinos ADD COLUMN tiene_aeropuerto TINYINT(1) DEFAULT 1",
        "ALTER TABLE destinos ADD COLUMN aeropuerto_cercano VARCHAR(150)",
        "ALTER TABLE destinos ADD COLUMN iata_cercano VARCHAR(10)",
        "ALTER TABLE destinos ADD COLUMN instrucciones_acceso TEXT",
        "ALTER TABLE destinos ADD COLUMN transporte_info TEXT",
        "ALTER TABLE destinos ADD COLUMN tiempo_terrestre VARCHAR(50)",
    ]
    for sql in migraciones:
        try:
            cursor.execute(sql)
            db.commit()
        except Exception:
            pass

    try:
        cursor.execute("UPDATE usuario SET tipo_usuario = 'admin' WHERE cedula = '1016947885'")
        db.commit()
    except Exception as e:
        print("❌ ERROR ADMIN:", e)

    cursor.close()
    db.close()

crear_tablas()


@app.route('/')
def home():
    return "Servidor Unix Travel funcionando 🔥"


# =========================
# 📸 IMÁGENES DE DESTINO
# =========================
@app.route('/imagenes_destino', methods=['GET'])
def imagenes_destino():
    ciudad = request.args.get('ciudad', '')
    imagen_admin = request.args.get('imagen_admin', '')
    try:
        imagenes = []
        if imagen_admin and imagen_admin.startswith('http'):
            imagenes.append(imagen_admin)
        cache_key = f"destino__{ciudad.lower()}"
        if cache_key in _imagenes_destino_cache:
            imgs_extra = _imagenes_destino_cache[cache_key]
            for img in imgs_extra:
                if img not in imagenes:
                    imagenes.append(img)
            return jsonify({"imagenes": imagenes[:8]})
        cantidad_buscar = 6 if imagen_admin else 7
        query = f"{ciudad} Colombia travel tourism landscape"
        imgs_unsplash = obtener_imagenes_unsplash_multiples(query, cantidad=cantidad_buscar, fallback=ciudad)
        for img in imgs_unsplash:
            if img not in imagenes:
                imagenes.append(img)
        ciudad_key = ciudad.lower()
        fallback_imgs = IMAGENES_CIUDADES_FALLBACK.get(ciudad_key, IMAGENES_CIUDADES_FALLBACK["default"])
        for img in fallback_imgs:
            if img not in imagenes and len(imagenes) < 8:
                imagenes.append(img)
        _imagenes_destino_cache[cache_key] = imagenes
        return jsonify({"imagenes": imagenes[:8]})
    except Exception as e:
        print(f"❌ Error imagenes_destino: {e}")
        ciudad_key = ciudad.lower()
        fallback = IMAGENES_CIUDADES_FALLBACK.get(ciudad_key, IMAGENES_CIUDADES_FALLBACK["default"])
        return jsonify({"imagenes": fallback})


# =========================
# ✈️ IMÁGENES DE AEROLÍNEA
# =========================
@app.route('/imagenes_aerolinea/<nombre>', methods=['GET'])
def imagenes_aerolinea(nombre):
    try:
        imagenes = obtener_imagenes_aerolinea_multiples(nombre)
        return jsonify({"aerolinea": nombre, "imagenes": imagenes, "total": len(imagenes)})
    except Exception as e:
        return jsonify({"imagenes": IMAGENES_AEROLINEAS_MULTIPLES["default"]})


# =========================
# 🔥 NUEVO: INFO DE ACCESO A DESTINO (sin aeropuerto / con escala)
# Retorna si tiene aeropuerto, cómo llegar, transporte desde ciudad cercana
# =========================
@app.route('/info_acceso_destino', methods=['GET'])
def info_acceso_destino():
    destino = request.args.get('destino', '').lower().strip()
    try:
        # 🔥 1. Primero buscar en la base de datos (lo que el admin configuró)
        try:
            db = get_db()
            cursor = db.cursor(dictionary=True)
            cursor.execute("SELECT * FROM destinos WHERE LOWER(nombre) = %s", (destino,))
            row = cursor.fetchone()
            cursor.close()
            db.close()
            if row:
                tiene = row.get("tiene_aeropuerto", 1)
                tiene_bool = tiene == 1 or tiene is True
                if not tiene_bool:
                    # Destino sin aeropuerto configurado por el admin
                    return jsonify({
                        "destino": destino,
                        "tiene_aeropuerto_directo": False,
                        "aeropuerto_cercano": row.get("aeropuerto_cercano", ""),
                        "codigo_iata_cercano": row.get("iata_cercano", "BOG"),
                        "tiempo_terrestre": row.get("tiempo_terrestre", ""),
                        "instrucciones": row.get("instrucciones_acceso", ""),
                        "nota": row.get("transporte_info", ""),
                        "transporte": [],
                        "fuente": "admin"
                    })
                else:
                    return jsonify({
                        "destino": destino,
                        "tiene_aeropuerto_directo": True,
                        "codigo_iata": row.get("codigo_iata", "") or row.get("iata_cercano", ""),
                        "instrucciones": f"Vuelos directos disponibles.",
                        "nota": "",
                        "fuente": "admin"
                    })
        except Exception as db_err:
            print(f"⚠️ DB error en info_acceso: {db_err}")

        # 🔥 2. Fallback: diccionario hardcodeado
        if destino in DESTINOS_SIN_AEROPUERTO:
            info = DESTINOS_SIN_AEROPUERTO[destino]
            return jsonify({
                "destino": destino,
                "tiene_aeropuerto_directo": info.get("tiene_aeropuerto", False),
                "aeropuerto_cercano": info.get("aeropuerto_cercano", ""),
                "codigo_iata_cercano": info.get("codigo_iata_cercano", "BOG"),
                "distancia_km": info.get("distancia_km", 0),
                "tiempo_terrestre": info.get("tiempo_terrestre", ""),
                "transporte": info.get("transporte", []),
                "instrucciones": info.get("instrucciones", ""),
                "nota": info.get("nota", ""),
                "fuente": "sistema"
            })

        # 🔥 3. Verificar si tiene IATA directo
        iata = CODIGOS_IATA.get(destino)
        if iata:
            return jsonify({
                "destino": destino,
                "tiene_aeropuerto_directo": True,
                "codigo_iata": iata,
                "instrucciones": f"Vuelos directos disponibles al aeropuerto {iata}.",
                "nota": "",
                "fuente": "sistema"
            })

        # 🔥 4. Desconocido → BOG por defecto
        return jsonify({
            "destino": destino,
            "tiene_aeropuerto_directo": False,
            "aeropuerto_cercano": "Bogotá (BOG)",
            "codigo_iata_cercano": "BOG",
            "instrucciones": f"No encontramos vuelos directos a {destino}. Te recomendamos volar a Bogotá y continuar por tierra.",
            "nota": f"Consulta con nosotros para planear el mejor acceso a {destino}.",
            "transporte": [
                {"tipo": "Bus", "descripcion": "Desde el terminal de Bogotá hay conexiones a múltiples destinos.", "precio_aprox": "Consultar", "duracion": "Variable"}
            ],
            "fuente": "sistema"
        })
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


# =========================
# ✈️ VUELOS REALES — IGNAV (con soporte de fecha y destinos sin aeropuerto)
# =========================
@app.route('/buscar_vuelos_reales', methods=['POST'])
def buscar_vuelos_reales():
    try:
        data = request.json
        origen = data.get('origen', 'BOG')
        destino_nombre = data.get('destino_nombre', '')  # nombre del destino en texto
        destino = data.get('destino', 'CTG')             # código IATA
        fecha = data.get('fecha')
        tipo = data.get('tipo', 'one-way')

        # 🔥 FIX: Si viene destino_nombre, resolver si tiene aeropuerto
        if destino_nombre:
            destino_key = destino_nombre.lower().strip()
            if destino_key in DESTINOS_SIN_AEROPUERTO:
                info = DESTINOS_SIN_AEROPUERTO[destino_key]
                if not info.get("tiene_aeropuerto", True):
                    # No tiene aeropuerto → redirigir a ciudad cercana
                    iata_cercano = info.get("codigo_iata_cercano", "BOG")
                    print(f"⚠️ {destino_nombre} sin aeropuerto → redirigiendo a {iata_cercano}")
                    destino = iata_cercano
            elif destino_key in CODIGOS_IATA:
                destino = CODIGOS_IATA[destino_key]

        print(f"🔍 Buscando vuelos: {origen} → {destino} el {fecha}")

        response = req.post(
            f"https://ignav.com/api/fares/{tipo}",
            headers={"X-Api-Key": IGNAV_API_KEY, "Content-Type": "application/json"},
            json={"origin": origen, "destination": destino, "departure_date": fecha},
            timeout=20
        )

        if response.status_code != 200:
            print(f"❌ Ignav error: {response.status_code}")
            return jsonify({"vuelos": [], "mensaje": "Sin resultados para esta fecha"}), 200

        data_api = response.json()
        vuelos = []

        for itinerario in data_api.get("itineraries", [])[:10]:
            outbound = itinerario.get("outbound", {})
            segmentos = outbound.get("segments", [])
            if not segmentos:
                continue
            primer_seg = segmentos[0]
            ultimo_seg = segmentos[-1]
            precio = itinerario.get("price", {})
            aerolinea = primer_seg.get("operating_carrier_name", "")
            precio_usd = precio.get('amount', 0)
            imagenes_vuelo = obtener_imagenes_aerolinea_multiples(aerolinea)

            vuelos.append({
                "origen": primer_seg.get("departure_airport", origen),
                "destino": ultimo_seg.get("arrival_airport", destino),
                "aerolinea": aerolinea,
                "numero_vuelo": f"{primer_seg.get('marketing_carrier_code', '')}{primer_seg.get('flight_number', '')}",
                "hora_salida": primer_seg.get("departure_time_local", "")[:16] if primer_seg.get("departure_time_local") else "",
                "hora_llegada": ultimo_seg.get("arrival_time_local", "")[:16] if ultimo_seg.get("arrival_time_local") else "",
                "duracion": f"{outbound.get('duration_minutes', 0)} min",
                "precio": usd_a_cop(precio_usd),
                "precio_usd": precio_usd,
                "moneda": "COP",
                "clase": itinerario.get("cabin_class", "economy"),
                "escalas": len(segmentos) - 1,
                "imagen": imagenes_vuelo[0],
                "imagenes": imagenes_vuelo,
                "ignav_id": itinerario.get("ignav_id", ""),
                "fuente": "real"
            })

        print(f"✅ Vuelos encontrados: {len(vuelos)}")
        return jsonify({"vuelos": vuelos})

    except Exception as e:
        print("❌ ERROR IGNAV:", e)
        return jsonify({"vuelos": [], "mensaje": str(e)}), 500


# =========================
# 🔥 NUEVO: PRECIO MÍNIMO POR DESTINOS (para mostrar "Vuelos desde $X" en home)
# =========================
@app.route('/precios_minimos_destinos', methods=['POST'])
def precios_minimos_destinos():
    """
    Recibe lista de destinos y fecha, retorna el precio mínimo de vuelo para cada uno.
    Usado en home_screen para mostrar "Vuelos desde $X" en todas las cards.
    """
    try:
        data = request.json
        destinos_lista = data.get('destinos', [])  # [{"nombre": "Cartagena", "iata": "CTG"}, ...]
        fecha = data.get('fecha')
        origen = data.get('origen', 'BOG')

        if not fecha:
            from datetime import datetime, timedelta
            fecha = (datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')

        resultados = {}

        for d in destinos_lista:
            nombre = d.get('nombre', '')
            iata = d.get('iata', '')

            # Resolver IATA si no viene
            if not iata:
                nombre_key = nombre.lower().strip()
                if nombre_key in DESTINOS_SIN_AEROPUERTO:
                    info = DESTINOS_SIN_AEROPUERTO[nombre_key]
                    if not info.get("tiene_aeropuerto", True):
                        iata = info.get("codigo_iata_cercano", "BOG")
                    else:
                        iata = info.get("codigo_iata", "BOG")
                else:
                    iata = CODIGOS_IATA.get(nombre_key, "")

            if not iata:
                resultados[nombre] = {"precio": "", "tiene_aeropuerto": False}
                continue

            try:
                resp = req.post(
                    "https://ignav.com/api/fares/one-way",
                    headers={"X-Api-Key": IGNAV_API_KEY, "Content-Type": "application/json"},
                    json={"origin": origen, "destination": iata, "departure_date": fecha},
                    timeout=15
                )
                if resp.status_code == 200:
                    vuelos_data = resp.json().get("itineraries", [])
                    if vuelos_data:
                        precio_min = min(
                            [v.get("price", {}).get("amount", 999999) for v in vuelos_data],
                            default=0
                        )
                        resultados[nombre] = {
                            "precio": usd_a_cop(precio_min),
                            "iata": iata,
                            "tiene_aeropuerto": True
                        }
                    else:
                        resultados[nombre] = {"precio": "", "iata": iata, "tiene_aeropuerto": True}
                else:
                    resultados[nombre] = {"precio": "", "iata": iata, "tiene_aeropuerto": True}
            except Exception as e:
                print(f"⚠️ Error precio {nombre}: {e}")
                resultados[nombre] = {"precio": "", "iata": iata, "tiene_aeropuerto": True}

        return jsonify({"precios": resultados})

    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500


# =========================
# 🏨 HOTELES REALES — LITEAPI
# =========================
@app.route('/buscar_hoteles_reales', methods=['POST'])
def buscar_hoteles_reales():
    try:
        data = request.json
        ciudad = data.get('ciudad', '')
        check_in = data.get('check_in')
        check_out = data.get('check_out')
        personas = data.get('personas', 2)

        print(f"🔍 Buscando hoteles LiteAPI para: {ciudad}")

        response = req.get(
            "https://api.liteapi.travel/v3.0/data/hotels",
            headers={"X-API-Key": LITEAPI_KEY, "accept": "application/json"},
            params={"countryCode": "CO", "cityName": ciudad, "language": "es", "limit": 10, "offset": 0},
            timeout=20
        )

        if response.status_code != 200:
            return _hoteles_locales(ciudad)

        data_api = response.json()
        lista = data_api.get("data", [])

        if not lista:
            return _hoteles_locales(ciudad)

        hoteles = []
        for hotel in lista[:10]:
            nombre_hotel = hotel.get("name", "")
            fotos = hotel.get("hotelImages", []) or hotel.get("images", [])
            imagen = ""
            if fotos:
                imagen = fotos[0].get("url", "") or fotos[0].get("link", "")
            if not imagen or not imagen.startswith("http"):
                query_hotel = f"{nombre_hotel} hotel {ciudad} exterior facade"
                imagen = obtener_imagen_unsplash(query_hotel, fallback=ciudad)
            if not imagen or not imagen.startswith("http"):
                imagen = obtener_imagen_ciudad_fallback(ciudad)

            precio_raw = hotel.get("minRate", "")
            try:
                if precio_raw:
                    precio_str = formatear_cop(float(precio_raw) * USD_A_COP)
                else:
                    precio_str = "Consultar"
            except:
                precio_str = "Consultar"

            hoteles.append({
                "nombre": nombre_hotel,
                "destino": ciudad,
                "precio_noche": precio_str,
                "precio_numero": str(precio_raw),
                "estrellas": int(hotel.get("starRating", 3) or 3),
                "descripcion": hotel.get("address", {}).get("line1", "") if isinstance(hotel.get("address"), dict) else str(hotel.get("address", "")),
                "imagen": imagen,
                "tipo_habitacion": "Doble",
                "incluye_desayuno": False,
                "capacidad": personas,
                "hotel_id": hotel.get("hotelId", ""),
                "fuente": "real"
            })

        print(f"✅ Hoteles LiteAPI encontrados: {len(hoteles)}")
        return jsonify({"hoteles": hoteles})

    except Exception as e:
        print("❌ ERROR LITEAPI:", e)
        return _hoteles_locales(ciudad)


def _hoteles_locales(ciudad):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM hoteles WHERE LOWER(destino) = LOWER(%s)", (ciudad,))
        datos = cursor.fetchall()
        for hotel in datos:
            if not hotel.get("imagen") or not hotel["imagen"].startswith("http"):
                nombre_hotel = hotel.get("nombre", "")
                query_hotel = f"{nombre_hotel} hotel {ciudad} exterior facade"
                hotel["imagen"] = obtener_imagen_unsplash(query_hotel, fallback=ciudad)
        cursor.close()
        db.close()
        return jsonify({"hoteles": datos})
    except Exception as e:
        return jsonify({"hoteles": [], "mensaje": str(e)}), 500


# =========================
# 🌍 DESTINOS
# =========================
@app.route('/agregar_destino', methods=['POST'])
def agregar_destino():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO destinos (nombre, descripcion, precio, imagen, categoria, precio_por_persona,
            incluye, duracion, codigo_iata, tiene_aeropuerto, aeropuerto_cercano, iata_cercano,
            instrucciones_acceso, transporte_info, tiempo_terrestre)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio'),
              data.get('imagen'), data.get('categoria'), data.get('precio_por_persona'),
              data.get('incluye'), data.get('duracion'), data.get('codigo_iata', ''),
              1 if data.get('tiene_aeropuerto', True) else 0,
              data.get('aeropuerto_cercano', ''), data.get('iata_cercano', ''),
              data.get('instrucciones_acceso', ''), data.get('transporte_info', ''),
              data.get('tiempo_terrestre', '')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Destino agregado correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_destinos', methods=['GET'])
def obtener_destinos():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM destinos")
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"destinos": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_destinos_categoria/<categoria>', methods=['GET'])
def obtener_destinos_categoria(categoria):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM destinos WHERE categoria = %s", (categoria,))
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"destinos": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/editar_destino/<int:id>', methods=['POST'])
def editar_destino(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE destinos SET nombre=%s, descripcion=%s, precio=%s, imagen=%s, categoria=%s,
            precio_por_persona=%s, incluye=%s, duracion=%s, codigo_iata=%s,
            tiene_aeropuerto=%s, aeropuerto_cercano=%s, iata_cercano=%s,
            instrucciones_acceso=%s, transporte_info=%s, tiempo_terrestre=%s
            WHERE id=%s
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio'),
              data.get('imagen'), data.get('categoria'), data.get('precio_por_persona'),
              data.get('incluye'), data.get('duracion'), data.get('codigo_iata', ''),
              1 if data.get('tiene_aeropuerto', True) else 0,
              data.get('aeropuerto_cercano', ''), data.get('iata_cercano', ''),
              data.get('instrucciones_acceso', ''), data.get('transporte_info', ''),
              data.get('tiempo_terrestre', ''), id))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Destino actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_destino/<int:id>', methods=['DELETE'])
def eliminar_destino(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM destinos WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Destino eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 🏨 HOTELES MYSQL
# =========================
@app.route('/agregar_hotel', methods=['POST'])
def agregar_hotel():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO hoteles (nombre, descripcion, precio_noche, imagen, destino, estrellas, tipo_habitacion, incluye_desayuno, capacidad)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio_noche'),
              data.get('imagen'), data.get('destino'), data.get('estrellas', 3),
              data.get('tipo_habitacion', 'Doble'), data.get('incluye_desayuno', False),
              data.get('capacidad', 2)))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Hotel agregado correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_hoteles', methods=['GET'])
def obtener_hoteles():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM hoteles")
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"hoteles": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/editar_hotel/<int:id>', methods=['POST'])
def editar_hotel(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE hoteles SET nombre=%s, descripcion=%s, precio_noche=%s, imagen=%s, destino=%s,
            estrellas=%s, tipo_habitacion=%s, incluye_desayuno=%s, capacidad=%s WHERE id=%s
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio_noche'),
              data.get('imagen'), data.get('destino'), data.get('estrellas', 3),
              data.get('tipo_habitacion', 'Doble'), data.get('incluye_desayuno', False),
              data.get('capacidad', 2), id))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Hotel actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_hotel/<int:id>', methods=['DELETE'])
def eliminar_hotel(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM hoteles WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Hotel eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# ✈️ VUELOS MYSQL
# =========================
@app.route('/agregar_vuelo', methods=['POST'])
def agregar_vuelo():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO vuelos (origen, destino, precio, imagen, aerolinea, duracion, numero_vuelo, hora_salida, hora_llegada, clase, precio_por_persona)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data.get('origen'), data.get('destino'), data.get('precio'),
              data.get('imagen'), data.get('aerolinea'), data.get('duracion'),
              data.get('numero_vuelo'), data.get('hora_salida'), data.get('hora_llegada'),
              data.get('clase', 'economica'), data.get('precio_por_persona')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Vuelo agregado correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_vuelos', methods=['GET'])
def obtener_vuelos():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM vuelos")
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"vuelos": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/editar_vuelo/<int:id>', methods=['POST'])
def editar_vuelo(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE vuelos SET origen=%s, destino=%s, precio=%s, imagen=%s, aerolinea=%s,
            duracion=%s, numero_vuelo=%s, hora_salida=%s, hora_llegada=%s,
            clase=%s, precio_por_persona=%s WHERE id=%s
        """, (data.get('origen'), data.get('destino'), data.get('precio'),
              data.get('imagen'), data.get('aerolinea'), data.get('duracion'),
              data.get('numero_vuelo'), data.get('hora_salida'), data.get('hora_llegada'),
              data.get('clase', 'economica'), data.get('precio_por_persona'), id))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Vuelo actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_vuelo/<int:id>', methods=['DELETE'])
def eliminar_vuelo(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM vuelos WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Vuelo eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 🎯 TOURS
# =========================
@app.route('/agregar_tour', methods=['POST'])
def agregar_tour():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO tours (nombre, descripcion, precio, imagen, destino, duracion, punto_encuentro, cupo_maximo, incluye, precio_por_persona)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio'),
              data.get('imagen'), data.get('destino'), data.get('duracion'),
              data.get('punto_encuentro'), data.get('cupo_maximo', 20),
              data.get('incluye'), data.get('precio_por_persona')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Tour agregado correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_tours', methods=['GET'])
def obtener_tours():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM tours")
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"tours": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/editar_tour/<int:id>', methods=['POST'])
def editar_tour(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE tours SET nombre=%s, descripcion=%s, precio=%s, imagen=%s, destino=%s,
            duracion=%s, punto_encuentro=%s, cupo_maximo=%s, incluye=%s, precio_por_persona=%s WHERE id=%s
        """, (data.get('nombre'), data.get('descripcion'), data.get('precio'),
              data.get('imagen'), data.get('destino'), data.get('duracion'),
              data.get('punto_encuentro'), data.get('cupo_maximo', 20),
              data.get('incluye'), data.get('precio_por_persona'), id))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Tour actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_tour/<int:id>', methods=['DELETE'])
def eliminar_tour(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM tours WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Tour eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 🛒 CARRITO
# =========================
@app.route('/agregar_carrito', methods=['POST'])
def agregar_carrito():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO carrito (usuario_cedula, nombre_producto, precio, imagen, fecha_ida, fecha_vuelta, personas, tipo, precio_total)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data.get('usuario_cedula'), data.get('nombre'), data.get('precio'),
              data.get('imagen'), data.get('fecha_ida'), data.get('fecha_vuelta'),
              data.get('personas', 1), data.get('tipo', 'destino'), data.get('precio_total')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Producto agregado al carrito"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_carrito/<cedula>', methods=['GET'])
def obtener_carrito(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM carrito WHERE usuario_cedula = %s", (cedula,))
        datos = cursor.fetchall()
        for item in datos:
            if item.get('fecha_ida'): item['fecha_ida'] = str(item['fecha_ida'])
            if item.get('fecha_vuelta'): item['fecha_vuelta'] = str(item['fecha_vuelta'])
        cursor.close()
        db.close()
        return jsonify({"carrito": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/editar_carrito/<int:id>', methods=['POST'])
def editar_carrito(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE carrito SET fecha_ida=%s, fecha_vuelta=%s, personas=%s, precio_total=%s WHERE id=%s
        """, (data.get('fecha_ida'), data.get('fecha_vuelta'),
              data.get('personas', 1), data.get('precio_total'), id))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Carrito actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_carrito/<int:id>', methods=['DELETE'])
def eliminar_carrito(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM carrito WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Producto eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 💳 PAGAR
# =========================
@app.route('/pagar/<cedula>', methods=['POST'])
def pagar(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM carrito WHERE usuario_cedula = %s", (cedula,))
        items = cursor.fetchall()
        if not items:
            return jsonify({"mensaje": "El carrito está vacío"}), 400
        cursor2 = db.cursor()
        for item in items:
            cursor2.execute("""
                INSERT INTO compras (usuario_cedula, nombre_producto, precio, imagen, fecha_ida, fecha_vuelta, personas, tipo, precio_total)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (item['usuario_cedula'], item['nombre_producto'], item['precio'],
                  item['imagen'], item['fecha_ida'], item['fecha_vuelta'],
                  item['personas'], item.get('tipo', 'destino'), item.get('precio_total')))
        cursor2.execute("DELETE FROM carrito WHERE usuario_cedula = %s", (cedula,))
        db.commit()
        cursor.close()
        cursor2.close()
        db.close()
        return jsonify({"mensaje": "Pago realizado y guardado en historial"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 📦 HISTORIAL
# =========================
@app.route('/mis_compras/<cedula>', methods=['GET'])
def mis_compras(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM compras WHERE usuario_cedula = %s ORDER BY fecha_compra DESC", (cedula,))
        datos = cursor.fetchall()
        for item in datos:
            if item.get('fecha_ida'): item['fecha_ida'] = str(item['fecha_ida'])
            if item.get('fecha_vuelta'): item['fecha_vuelta'] = str(item['fecha_vuelta'])
            if item.get('fecha_compra'): item['fecha_compra'] = str(item['fecha_compra'])
        cursor.close()
        db.close()
        return jsonify({"compras": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 📝 SOLICITUDES
# =========================
@app.route('/solicitar_edicion', methods=['POST'])
def solicitar_edicion():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            INSERT INTO solicitudes_edicion (compra_id, usuario_cedula, fecha_ida_nueva, fecha_vuelta_nueva, personas_nueva, motivo)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (data.get('compra_id'), data.get('usuario_cedula'), data.get('fecha_ida_nueva'),
              data.get('fecha_vuelta_nueva'), data.get('personas_nueva'), data.get('motivo')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Solicitud enviada al admin correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/mis_solicitudes/<cedula>', methods=['GET'])
def mis_solicitudes(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT s.*, c.nombre_producto, c.imagen, c.tipo
            FROM solicitudes_edicion s
            JOIN compras c ON s.compra_id = c.id
            WHERE s.usuario_cedula = %s ORDER BY s.fecha_solicitud DESC
        """, (cedula,))
        datos = cursor.fetchall()
        for item in datos:
            for campo in ['fecha_ida_nueva', 'fecha_vuelta_nueva', 'fecha_solicitud', 'fecha_respuesta']:
                if item.get(campo): item[campo] = str(item[campo])
        cursor.close()
        db.close()
        return jsonify({"solicitudes": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/admin/solicitudes', methods=['GET'])
def admin_solicitudes():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT s.*, c.nombre_producto, c.imagen, c.tipo, u.nombre, u.apellidos, u.email
            FROM solicitudes_edicion s
            JOIN compras c ON s.compra_id = c.id
            JOIN usuario u ON s.usuario_cedula = u.cedula
            ORDER BY s.fecha_solicitud DESC
        """)
        datos = cursor.fetchall()
        for item in datos:
            for campo in ['fecha_ida_nueva', 'fecha_vuelta_nueva', 'fecha_solicitud', 'fecha_respuesta']:
                if item.get(campo): item[campo] = str(item[campo])
        cursor.close()
        db.close()
        return jsonify({"solicitudes": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/admin/responder_solicitud/<int:id>', methods=['POST'])
def responder_solicitud(id):
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM solicitudes_edicion WHERE id = %s", (id,))
        solicitud = cursor.fetchone()
        if not solicitud:
            return jsonify({"mensaje": "Solicitud no encontrada"}), 404
        estado = data.get('estado')
        respuesta = data.get('respuesta_admin')
        cursor2 = db.cursor()
        if estado == 'aprobada':
            cursor2.execute("""
                UPDATE compras SET fecha_ida=%s, fecha_vuelta=%s, personas=%s WHERE id=%s
            """, (solicitud['fecha_ida_nueva'], solicitud['fecha_vuelta_nueva'],
                  solicitud['personas_nueva'], solicitud['compra_id']))
        cursor2.execute("""
            UPDATE solicitudes_edicion SET estado=%s, respuesta_admin=%s, fecha_respuesta=NOW() WHERE id=%s
        """, (estado, respuesta, id))
        db.commit()
        cursor.close()
        cursor2.close()
        db.close()
        return jsonify({"mensaje": f"Solicitud {estado} correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 📸 FOTO PERFIL
# =========================
@app.route('/subir_foto_perfil', methods=['POST'])
def subir_foto_perfil():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("UPDATE usuario SET foto_perfil=%s WHERE cedula=%s",
                      (data.get('foto_base64'), data.get('cedula')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Foto actualizada correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 📊 ADMIN — DASHBOARD
# =========================
@app.route('/admin/stats', methods=['GET'])
def admin_stats():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) as total FROM usuario WHERE tipo_usuario = 'cliente'")
        total_usuarios = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM compras")
        total_reservas = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM destinos")
        total_destinos = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM hoteles")
        total_hoteles = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM vuelos")
        total_vuelos = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM tours")
        total_tours = cursor.fetchone()["total"]
        cursor.execute("SELECT COUNT(*) as total FROM solicitudes_edicion WHERE estado = 'pendiente'")
        total_solicitudes = cursor.fetchone()["total"]
        cursor.close()
        db.close()
        return jsonify({
            "total_usuarios": total_usuarios,
            "total_reservas": total_reservas,
            "total_destinos": total_destinos,
            "total_hoteles": total_hoteles,
            "total_vuelos": total_vuelos,
            "total_tours": total_tours,
            "total_solicitudes_pendientes": total_solicitudes,
        })
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 👥 ADMIN — USUARIOS
# =========================
@app.route('/admin/usuarios', methods=['GET'])
def admin_usuarios():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT cedula, nombre, apellidos, email, telefono, tipo_usuario, foto_perfil FROM usuario")
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"usuarios": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/admin/perfil_usuario/<cedula>', methods=['GET'])
def admin_perfil_usuario(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE cedula = %s", (cedula,))
        usuario = cursor.fetchone()
        cursor.execute("SELECT * FROM compras WHERE usuario_cedula = %s ORDER BY fecha_compra DESC", (cedula,))
        compras = cursor.fetchall()
        cursor.execute("SELECT * FROM favoritos WHERE usuario_cedula = %s", (cedula,))
        favoritos = cursor.fetchall()
        cursor.execute("SELECT * FROM solicitudes_edicion WHERE usuario_cedula = %s ORDER BY fecha_solicitud DESC", (cedula,))
        solicitudes = cursor.fetchall()
        for item in compras:
            for campo in ['fecha_ida', 'fecha_vuelta', 'fecha_compra']:
                if item.get(campo): item[campo] = str(item[campo])
        for item in solicitudes:
            for campo in ['fecha_ida_nueva', 'fecha_vuelta_nueva', 'fecha_solicitud', 'fecha_respuesta']:
                if item.get(campo): item[campo] = str(item[campo])
        cursor.close()
        db.close()
        return jsonify({"usuario": usuario, "compras": compras, "favoritos": favoritos, "solicitudes": solicitudes})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/admin/cambiar_rol', methods=['POST'])
def cambiar_rol():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("UPDATE usuario SET tipo_usuario=%s WHERE cedula=%s",
                      (data.get('tipo_usuario'), data.get('cedula')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Rol actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/admin/eliminar_usuario/<cedula>', methods=['DELETE'])
def admin_eliminar_usuario(cedula):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM usuario WHERE cedula = %s", (cedula,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Usuario eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 📦 ADMIN — RESERVAS
# =========================
@app.route('/admin/reservas', methods=['GET'])
def admin_reservas():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("""
            SELECT c.*, u.nombre, u.apellidos, u.email
            FROM compras c JOIN usuario u ON c.usuario_cedula = u.cedula
            ORDER BY c.fecha_compra DESC
        """)
        datos = cursor.fetchall()
        for item in datos:
            for campo in ['fecha_ida', 'fecha_vuelta', 'fecha_compra']:
                if item.get(campo): item[campo] = str(item[campo])
        cursor.close()
        db.close()
        return jsonify({"reservas": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# ❤️ FAVORITOS
# =========================
@app.route('/toggle_favorito', methods=['POST'])
def toggle_favorito():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM favoritos WHERE usuario_cedula=%s AND nombre_producto=%s",
                      (data.get('usuario_cedula'), data.get('nombre')))
        existe = cursor.fetchone()
        cursor2 = db.cursor()
        if existe:
            cursor2.execute("DELETE FROM favoritos WHERE id=%s", (existe["id"],))
            db.commit()
            cursor.close(); cursor2.close(); db.close()
            return jsonify({"estado": "eliminado"})
        else:
            cursor2.execute("""
                INSERT INTO favoritos (usuario_cedula, nombre_producto, precio, imagen)
                VALUES (%s, %s, %s, %s)
            """, (data.get('usuario_cedula'), data.get('nombre'), data.get('precio'), data.get('imagen')))
            db.commit()
            cursor.close(); cursor2.close(); db.close()
            return jsonify({"estado": "agregado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/es_favorito', methods=['POST'])
def es_favorito():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM favoritos WHERE usuario_cedula=%s AND nombre_producto=%s",
                      (data.get('usuario_cedula'), data.get('nombre')))
        existe = cursor.fetchone()
        cursor.close()
        db.close()
        return jsonify({"es_favorito": True if existe else False})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/obtener_favoritos/<cedula>', methods=['GET'])
def obtener_favoritos(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM favoritos WHERE usuario_cedula = %s", (cedula,))
        datos = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify({"favoritos": datos})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/eliminar_favorito/<int:id>', methods=['DELETE'])
def eliminar_favorito(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM favoritos WHERE id = %s", (id,))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Favorito eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

# =========================
# 👤 USUARIOS
# =========================
@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.json
        if not data:
            return jsonify({"mensaje": "No se enviaron datos"}), 400
        cedula = data.get('cedula')
        nombre = data.get('nombre')
        apellidos = data.get('apellidos')
        email = data.get('email')
        password = data.get('password')
        telefono = data.get('telefono')
        if not all([cedula, nombre, apellidos, email, password, telefono]):
            return jsonify({"mensaje": "Todos los campos son obligatorios"}), 400
        if not cedula.isdigit() or not (6 <= len(cedula) <= 12):
            return jsonify({"mensaje": "Cédula inválida"}), 400
        if not telefono.isdigit() or len(telefono) != 10:
            return jsonify({"mensaje": "Teléfono inválido"}), 400
        if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
            return jsonify({"mensaje": "Correo inválido"}), 400
        db = get_db()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM usuario WHERE cedula = %s", (cedula,))
        if cursor.fetchone():
            cursor.close(); db.close()
            return jsonify({"mensaje": "La cédula ya existe"}), 400
        cursor.execute("""
            INSERT INTO usuario (cedula, nombre, apellidos, email, `contraseña`, telefono, tipo_usuario)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (cedula, nombre, apellidos, email, password, telefono, "cliente"))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Usuario registrado correctamente"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE cedula=%s AND email=%s AND `contraseña`=%s",
                      (data.get('cedula'), data.get('email'), data.get('password')))
        usuario = cursor.fetchone()
        cursor.close()
        db.close()
        if usuario:
            return jsonify({"usuario": usuario}), 200
        else:
            return jsonify({"mensaje": "Datos incorrectos"}), 401
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/user/<cedula>', methods=['GET'])
def get_user(cedula):
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuario WHERE cedula=%s", (cedula,))
        usuario = cursor.fetchone()
        cursor.close()
        db.close()
        if usuario:
            return jsonify({"usuario": usuario}), 200
        else:
            return jsonify({"mensaje": "Usuario no encontrado"}), 404
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/update_user', methods=['POST'])
def update_user():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("""
            UPDATE usuario SET nombre=%s, apellidos=%s, email=%s, telefono=%s WHERE cedula=%s
        """, (data.get('nombre'), data.get('apellidos'),
              data.get('email'), data.get('telefono'), data.get('cedula')))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Usuario actualizado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

@app.route('/delete_user', methods=['POST'])
def delete_user():
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM usuario WHERE cedula=%s", (data.get('cedula'),))
        db.commit()
        cursor.close()
        db.close()
        return jsonify({"mensaje": "Usuario eliminado"})
    except Exception as e:
        return jsonify({"mensaje": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)