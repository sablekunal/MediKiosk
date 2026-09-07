import pytest

from app.engine.extractor import ConstrainedExtractor


@pytest.mark.asyncio
async def test_rule_fallback_extracts_a_bounded_severity():
    result = await ConstrainedExtractor().extract("severity", "It is about 7 out of 10")
    assert result.value == 7
    assert result.engine == "rules"
