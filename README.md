<h3 align="center"> 🏭 Situación financiera de las 10.000 empresas más grandes de Colombia </h3>

## 🎯 Descripción del Proyecto
Este proyecto ha sido creado con el propósito de obtener valor sobre los datos financieros de las 10.000 empresas más grandes de Colombia. Esta información es ofrecida por la Superintendencia de Sociedades, la cual reporta de forma anual los balances financieros de las 10.000 con mayor relevancia económica para un período específico comprendido entre los años 2021 a 2024. La ingesta de datos fue hecha mediante una API pública y luego procesar la información bruta y convertirla en insights valiosos que pueden ser útiles a persona interesadas en inversión y gobierno.

## Índice
1. Propósito del proyecto
1. [Stack Tecnológico](#stack)
2. [Arquitectura de Datos](#arquitectura)
3. [Instalación y Uso](#instalación)
4. [Análisis y Hallazgos](#análisis)

## 💡 Propósito del proyecto
La implementación se basó en diseñar una arquitectura ETL que extrajo, procesó, limpió y cargó los datos crudos obtenidos que suelen presentarse en un formato complejo (JSON) y ruidoso para generar información accionable que permita tomar decisiones acertadas. El resultado permite visualizar el panorama empresarial colombiano de manera automatizada, buscando responder preguntas como:
  
  🧮 ¿Qué empresas han tenido un crecimiento positivo en su ganancia durante todos los años registrados? <br>
  🥇 En cada ciudad, ¿qué porcentaje de los ingresos totales de su sector captura la empresa líder? <br>
  📊 ¿En qué departamentos de Colombia es más estratégico invertir según el macrosector económico?
   



## 🏗️ Arquitectura de Datos
El proyecto fue construido bajo un pipeline end-to-end automatizado que extrae los datos financieros más recientes de las empresas alojados en un servidor y compartidos a través de datos.gov.co. Se realiza la petición para consumo de datos y los devuelve a través de la API  en formato JSON.



## 🛠️ Stack Tecnológico
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![SQL](https://img.shields.io/badge/sql-%2307405e.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Power Bi](https://img.shields.io/badge/power_bi-F2C811?style=for-the-badge&logo=microsoftpowerbi&logoColor=black)
![API](https://img.shields.io/badge/API-REST-orange?style=for-the-badge&logo=api&logoColor=white)




