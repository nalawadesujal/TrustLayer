from flask import current_app

def allowed_file(filename, modality):
    """Checks if the filename has an extension allowed for the specified modality."""
    if '.' not in filename:
        return False
    ext = filename.rsplit('.', 1)[1].lower()
    allowed_exts = current_app.config['ALLOWED_EXTENSIONS'].get(modality, set())
    return ext in allowed_exts
