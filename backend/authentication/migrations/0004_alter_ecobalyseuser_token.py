# Generated by Django 5.0.4 on 2024-05-19 15:29

import uuid

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("authentication", "0003_alter_ecobalyseuser_organization"),
    ]

    operations = [
        migrations.AlterField(
            model_name="ecobalyseuser",
            name="token",
            field=models.CharField(
                db_index=True,
                default=uuid.uuid4,
                editable=False,
                max_length=36,
                verbose_name="TOKEN",
            ),
        ),
    ]
