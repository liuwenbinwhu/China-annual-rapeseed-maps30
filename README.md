# China-annual-rapeseed-maps30
Code for: China annual rapeseed maps at 30 m spatial resolution from 2000 to 2022 using multi-source data
#
Rapeseed is a critical cash crop globally, and understanding its distribution can assist in refined agricultural management, ensuring a sustainable vegetable oil supply, 
and informing government decisions. China is the leading consumer and third-largest producer of rapeseed. However, there is a lack of widely available, long-term, 
and large-scale remotely sensed maps on rapeseed cultivation in China. Here this study utilizes multi-source data such as satellite images, GLDAS environmental variables, 
land cover maps, and terrain data to create the China annual rapeseed maps at 30 m spatial resolution from 2000 to 2022 (CARM30). Our product was validated using independent 
samples and showed average F1 scores of 0.869 and 0.971 for winter and spring rapeseed. The CARM30 has high spatial consistency with existing 10 m and 20 m rapeseed maps. 
Additionally, the CARM30-derived rapeseed planted area was significantly correlated with agricultural statistics (R2 = 0.65–0.86; p < 0.001). The obtained rapeseed distribution 
information can serve as a reference for stakeholders such as farmers, scientific communities, and decision-makers. 

#
☆estimate_rapeseed_flowering_time.m: MATLAB code for estimating the peak flowering date of rapeseed  
#
☆RFR_model_20220725.mat: Random forest regression model trained for estimating the flowering date of rapeseed
#
☆training_data.csv: Training data for estimating flowering dates of rapeseed 
#
☆20××_mete_data.tif: Input features for estimating flowering dates in rapeseed 
#
☆20××_floweringDOY.tif & 20××_floweringDOY_month.tif: Obtained maps of peak flowering dates for rapeseed
#
☆GEE-Rapeseed classification algorithm.txt: Code used to map rapeseed in the GEE cloud platform
#
☆Rapeseed-area.xlsx: Remotely sensed rapeseed planted area and statistical rapeseed planted area
#
☆China_springRapeseed_20××_uncertainty.tif & China_winterRapeseed_20××_uncertainty.tif: Uncertainty maps ☆corresponding to the CARM30 product
