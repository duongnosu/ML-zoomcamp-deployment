FROM public.ecr.aws/lambda/python:3.14
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

COPY pyproject.toml uv.lock ./
RUN uv pip install --system -r <(uv export --format requirements-txt --no-emit-project)

COPY lambda_function.py model.bin ./

CMD ["lambda_function.lambda_handler"]