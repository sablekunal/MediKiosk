from enum import StrEnum

from pydantic import BaseModel, Field


class AgniType(StrEnum):
    MANDA = "Manda"
    TIKSHNA = "Tikshna"
    VISHAMA = "Vishama"
    SAMA = "Sama"


class KoshthaType(StrEnum):
    KRURA = "Krura"
    MADHYAMA = "Madhyama"
    MRIDU = "Mridu"


class DoshaConstitution(StrEnum):
    VATA = "Vata"
    PITTA = "Pitta"
    KAPHA = "Kapha"
    VATA_PITTA = "Vata-Pitta"
    PITTA_KAPHA = "Pitta-Kapha"
    KAPHA_VATA = "Kapha-Vata"
    SANNIPATA = "Sannipata"


class DashavidhaPariksha(BaseModel):
    dushya: str | None = Field(default=None, max_length=250)
    desha: str | None = Field(default=None, max_length=250)
    bala: str | None = Field(default=None, max_length=250)
    kala: str | None = Field(default=None, max_length=250)
    anala: str | None = Field(default=None, max_length=250)
    prakriti: DoshaConstitution | None = None
    vayas: str | None = Field(default=None, max_length=100)
    sattva: str | None = Field(default=None, max_length=250)
    satmya: str | None = Field(default=None, max_length=250)
    ahara: str | None = Field(default=None, max_length=250)


class AharaVihara(BaseModel):
    dietary_patterns: list[str] = Field(default_factory=list, max_length=15)
    meal_regularity: str | None = Field(default=None, max_length=200)
    nidra: str | None = Field(default=None, max_length=200)
    vyayama: str | None = Field(default=None, max_length=200)


class AyurvedicProfile(BaseModel):
    agni: AgniType | None = None
    koshtha: KoshthaType | None = None
    prakriti: DoshaConstitution | None = None
    vikriti: DoshaConstitution | None = None
    dashavidha: DashavidhaPariksha = Field(default_factory=DashavidhaPariksha)
    ahara_vihara: AharaVihara = Field(default_factory=AharaVihara)
    nidana: list[str] = Field(default_factory=list, max_length=20)
