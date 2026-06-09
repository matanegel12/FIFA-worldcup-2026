import 'dart:math';

import '../../models/team.dart';

/// Maps API-Football team names to our Team domain model.
/// API-Football returns team names as plain strings — this table
/// adds the FIFA code and ISO code needed for flag display.
const Map<String, Team> kTeamMappings = {
  // Americas
  'Mexico':               Team(fifaCode: 'MEX', isoCode: 'mx',     name: 'Mexico'),
  'South Africa':         Team(fifaCode: 'RSA', isoCode: 'za',     name: 'South Africa'),
  'South Korea':          Team(fifaCode: 'KOR', isoCode: 'kr',     name: 'South Korea'),
  'Canada':               Team(fifaCode: 'CAN', isoCode: 'ca',     name: 'Canada'),
  'USA':                  Team(fifaCode: 'USA', isoCode: 'us',     name: 'USA'),
  'United States':        Team(fifaCode: 'USA', isoCode: 'us',     name: 'USA'),
  'Brazil':               Team(fifaCode: 'BRA', isoCode: 'br',     name: 'Brazil'),
  'Argentina':            Team(fifaCode: 'ARG', isoCode: 'ar',     name: 'Argentina'),
  'Uruguay':              Team(fifaCode: 'URU', isoCode: 'uy',     name: 'Uruguay'),
  'Colombia':             Team(fifaCode: 'COL', isoCode: 'co',     name: 'Colombia'),
  'Ecuador':              Team(fifaCode: 'ECU', isoCode: 'ec',     name: 'Ecuador'),
  'Peru':                 Team(fifaCode: 'PER', isoCode: 'pe',     name: 'Peru'),
  'Chile':                Team(fifaCode: 'CHI', isoCode: 'cl',     name: 'Chile'),
  'Venezuela':            Team(fifaCode: 'VEN', isoCode: 've',     name: 'Venezuela'),
  'Paraguay':             Team(fifaCode: 'PAR', isoCode: 'py',     name: 'Paraguay'),
  'Bolivia':              Team(fifaCode: 'BOL', isoCode: 'bo',     name: 'Bolivia'),
  'Haiti':                Team(fifaCode: 'HAI', isoCode: 'ht',     name: 'Haiti'),
  // Europe
  'France':               Team(fifaCode: 'FRA', isoCode: 'fr',     name: 'France'),
  'England':              Team(fifaCode: 'ENG', isoCode: 'gb-eng', name: 'England'),
  'Germany':              Team(fifaCode: 'GER', isoCode: 'de',     name: 'Germany'),
  'Spain':                Team(fifaCode: 'ESP', isoCode: 'es',     name: 'Spain'),
  'Portugal':             Team(fifaCode: 'POR', isoCode: 'pt',     name: 'Portugal'),
  'Netherlands':          Team(fifaCode: 'NED', isoCode: 'nl',     name: 'Netherlands'),
  'Belgium':              Team(fifaCode: 'BEL', isoCode: 'be',     name: 'Belgium'),
  'Croatia':              Team(fifaCode: 'CRO', isoCode: 'hr',     name: 'Croatia'),
  'Switzerland':          Team(fifaCode: 'SUI', isoCode: 'ch',     name: 'Switzerland'),
  'Serbia':               Team(fifaCode: 'SRB', isoCode: 'rs',     name: 'Serbia'),
  'Poland':               Team(fifaCode: 'POL', isoCode: 'pl',     name: 'Poland'),
  'Ukraine':              Team(fifaCode: 'UKR', isoCode: 'ua',     name: 'Ukraine'),
  'Turkey':               Team(fifaCode: 'TUR', isoCode: 'tr',     name: 'Turkey'),
  'Austria':              Team(fifaCode: 'AUT', isoCode: 'at',     name: 'Austria'),
  'Denmark':              Team(fifaCode: 'DEN', isoCode: 'dk',     name: 'Denmark'),
  'Scotland':             Team(fifaCode: 'SCO', isoCode: 'gb-sct', name: 'Scotland'),
  'Slovenia':             Team(fifaCode: 'SVN', isoCode: 'si',     name: 'Slovenia'),
  'Slovakia':             Team(fifaCode: 'SVK', isoCode: 'sk',     name: 'Slovakia'),
  'Romania':              Team(fifaCode: 'ROU', isoCode: 'ro',     name: 'Romania'),
  'Hungary':              Team(fifaCode: 'HUN', isoCode: 'hu',     name: 'Hungary'),
  // Africa
  'Morocco':              Team(fifaCode: 'MAR', isoCode: 'ma',     name: 'Morocco'),
  'Senegal':              Team(fifaCode: 'SEN', isoCode: 'sn',     name: 'Senegal'),
  'Nigeria':              Team(fifaCode: 'NGA', isoCode: 'ng',     name: 'Nigeria'),
  'Ghana':                Team(fifaCode: 'GHA', isoCode: 'gh',     name: 'Ghana'),
  'Cameroon':             Team(fifaCode: 'CMR', isoCode: 'cm',     name: 'Cameroon'),
  'Egypt':                Team(fifaCode: 'EGY', isoCode: 'eg',     name: 'Egypt'),
  'Tunisia':              Team(fifaCode: 'TUN', isoCode: 'tn',     name: 'Tunisia'),
  'Algeria':              Team(fifaCode: 'ALG', isoCode: 'dz',     name: 'Algeria'),
  'Mali':                 Team(fifaCode: 'MLI', isoCode: 'ml',     name: 'Mali'),
  // Asia / Middle East
  'Saudi Arabia':         Team(fifaCode: 'KSA', isoCode: 'sa',     name: 'Saudi Arabia'),
  'Iran':                 Team(fifaCode: 'IRN', isoCode: 'ir',     name: 'Iran'),
  'Qatar':                Team(fifaCode: 'QAT', isoCode: 'qa',     name: 'Qatar'),
  'Japan':                Team(fifaCode: 'JPN', isoCode: 'jp',     name: 'Japan'),
  // Oceania / Rest
  'Australia':            Team(fifaCode: 'AUS', isoCode: 'au',     name: 'Australia'),
  'New Zealand':          Team(fifaCode: 'NZL', isoCode: 'nz',     name: 'New Zealand'),
  'Indonesia':            Team(fifaCode: 'IDN', isoCode: 'id',     name: 'Indonesia'),
};

/// Looks up a team by API-Football name.
/// Returns a fallback Team if the name is not in the mapping table.
Team teamFromApiName(String apiName) {
  return kTeamMappings[apiName] ??
      Team(
        fifaCode: apiName.substring(0, min(3, apiName.length)).toUpperCase(),
        isoCode: 'un',
        name: apiName,
      );
}
