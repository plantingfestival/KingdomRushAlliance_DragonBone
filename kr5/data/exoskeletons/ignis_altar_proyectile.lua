return {
	fps = 30,
	partScaleCompensation = 1,
	animations = {
		{
			name = "run",
			frames = {
				{
					parts = {
						{
							name = "asst_torre_volcan_proyectil_fuego",
							alpha = nil,
							xform = {
								sx = 1,
								ky = 0,
								kx = 0,
								sy = 1,
								x = 0.7,
								y = 0.2,
								r = 0
							}
						},
						{
							name = "asst_torre_volcan_proyectl_bola",
							alpha = nil,
							xform = {
								sx = 1,
								ky = 0,
								kx = 0,
								sy = 1,
								x = 0.15,
								y = 0.2,
								r = 0
							}
						}
					}
				}
			}
		}
	},
	parts = {
		asst_torre_volcan_proyectil_fuego = {
			name = "asst_torre_volcan_proyectil_fuego",
			offsetX = 0,
			offsetY = 0
		},
		asst_torre_volcan_proyectl_bola = {
			name = "asst_torre_volcan_proyectl_bola",
			offsetX = 0,
			offsetY = 0
		}
	}
}